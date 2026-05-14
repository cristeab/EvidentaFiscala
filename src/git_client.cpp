#include "git_client.h"
#include "settings.h"
#include "git2.h"
#include <QDebug>

template<class T, void (*releaseCallback)(T*)>
class Proxy {
public:
    ~Proxy() {
        if (_d) {
            releaseCallback(_d);
        }
    }
    operator T**() {
        return &_d;
    }
    operator T*() {
        return _d;
    }
private:
    T* _d{};
};

static
constexpr QString gitError(QString const& prefix) {
    auto const* err = git_error_last();
    return prefix + ": " + (err ? err->message : "Unknown error");
}

GitClient::GitClient(const Settings *settings)
    : _settings{settings}
{
    auto const error = git_libgit2_init();
    if (0 >= error) {
        qCritical() << gitError("Cannot init libgit2");
        return;
    }
    qDebug() << "libgit2 initialized";
}

GitClient::~GitClient()
{
    if (_repo) {
        git_repository_free(_repo);
    }
    git_libgit2_shutdown();
    qDebug() << "libgit2 shutdown";
}

std::expected<GitClient::RepoStatus,QString> GitClient::initRepo()
{
    if (_settings.isNull()) {
        return std::unexpected("Invalid settings object");
    }

    auto const& repoPath = _settings->workingFolderPath().toStdString();
    auto error = git_repository_open_ext(
        NULL,
        repoPath.c_str(),
        GIT_REPOSITORY_OPEN_NO_SEARCH,
        NULL
        );
    switch (error) {
    case 0:
        return RepoStatus::AlreadyCreated;
    case GIT_ENOTFOUND:
        qDebug() << "No Git repository found. Initializing a new one";
        error = git_repository_init(&_repo, repoPath.c_str(), 0);
        if (0 != error) {
            return std::unexpected(gitError("Failed to init repository"));
        }
        return RepoStatus::Created;
    default:;
    }
    return std::unexpected(gitError("Error during repository detection"));
}

std::expected<void, QString> GitClient::openRepo()
{
    if (_repo) {
        qDebug() << "Repo already open";
        return {};
    }
    if (_settings.isNull()) {
        return std::unexpected("Invalid settings object");
    }

    auto const& repoPath = _settings->workingFolderPath();
    if (repoPath.isEmpty()) {
        return std::unexpected("Repository path is empty");
    }

    auto error = git_repository_open(&_repo, repoPath.toStdString().c_str());
    if (0 > error) {
        git_repository_free(_repo);
        _repo = nullptr;
        return std::unexpected(gitError("Failed to init repository"));
    }
    return {};
}

void appendToFileList(GitClient* self, const QString& path, int status)
{
    if (static_cast<GitClient::FileStatus>(status) == self->_fileStatus) {
        self->_files.append(path);
    }
}

static
int eachFileCb(const git_diff_delta *delta, float /*progress*/, void *payload)
{
    GitClient* client = static_cast<GitClient*>(payload);

    // Access the path of the 'new' file in the diff
    const char *path = delta->new_file.path;

    switch (delta->status) {
    case GIT_DELTA_ADDED:
        appendToFileList(client, path, static_cast<int>(GitClient::FileStatus::Added));
        break;
    case GIT_DELTA_DELETED:
        appendToFileList(client, path, static_cast<int>(GitClient::FileStatus::Deleted));
        break;
    case GIT_DELTA_MODIFIED:
        appendToFileList(client, path, static_cast<int>(GitClient::FileStatus::Modified));
        break;
    case GIT_DELTA_RENAMED:
        appendToFileList(client, path, static_cast<int>(GitClient::FileStatus::Renamed));
        break;
    case GIT_DELTA_UNTRACKED:
        appendToFileList(client, path, static_cast<int>(GitClient::FileStatus::Untracked));
        break;
    default:;
    }

    return 0;
}

QStringList const& GitClient::filesWithStatus(FileStatus status)
{
    _files.clear();
    if (!_repo) {
        qCritical() << "Repository not open";
        return _files;
    }
    _fileStatus = status;

    Proxy<git_diff, git_diff_free> diff;
    if (git_diff_index_to_workdir(diff, _repo, NULL, NULL) < 0) {
        qCritical() << gitError("Cannot retrieve files from repo");
        return _files;
    }

    git_diff_foreach(diff, eachFileCb, NULL, NULL, NULL, this);

    return _files;
}

std::expected<void,QString> GitClient::stageAndCommit(QString const& filePath, QString const& commitMessage)
{
    if (!_repo) {
        return std::unexpected("Repository not open");
    }
    if (_settings.isNull()) {
        return std::unexpected("Invalid settings object");
    }

    // Open the repository index (staging area)
    Proxy<git_index,git_index_free> index;
    if (git_repository_index(index, _repo) != 0) {
        return std::unexpected(gitError("Cannot open the repo index"));
    }

    // Stage the modified file
    if (git_index_add_bypath(index, filePath.toStdString().c_str()) != 0) {
        return std::unexpected(gitError("Cannot stage the modified file"));
    }

    // Write index changes back to disk
    if (git_index_write(index) != 0) {
        return std::unexpected(gitError("Cannot write index"));
    }

    // Write the current index state into a structural tree object
    git_oid treeId;
    if (git_index_write_tree(&treeId, index) != 0) {
        return std::unexpected(gitError("Cannot write the index state"));
    }

    Proxy<git_tree,git_tree_free> tree;
    if (git_tree_lookup(tree, _repo, &treeId) != 0) {
        return std::unexpected(gitError("Cannot lookup into tree"));
    }

    // Get the current HEAD commit to use as the parent object
    git_oid parentId;
    Proxy<git_commit,git_commit_free> parent;
    int hasParent = 0;
    if (git_reference_name_to_id(&parentId, _repo, "HEAD") == 0) {
        if (git_commit_lookup(parent, _repo, &parentId) == 0) {
            hasParent = 1;
        }
    }

    // Create an author and committer signature using current time
    Proxy<git_signature,git_signature_free> signature{};
    if (git_signature_now(signature,
                          _settings->userName().toStdString().c_str(),
                          _settings->userEmail().toStdString().c_str()
                          ) != 0) {
        return std::unexpected(gitError("Cannot create commit signature"));
    }

    // Create the commit pointing to the new tree and parent
    git_oid commitId;
    const git_commit *parents[1] = { parent };
    if (git_commit_create(
            &commitId,
            _repo,
            "HEAD",            // Target reference to update automatically
            signature,         // Author
            signature,         // Committer
            NULL,              // Message encoding (defaults to UTF-8)
            commitMessage.toStdString().c_str(),    // Commit message text
            tree,              // Root tree object for this commit
            hasParent,        // Number of parent commits (0 for root commit)
            parents            // Array of parent commit pointers
            ) != 0) {
        return std::unexpected(gitError("Cannot create commit"));
    }

    qInfo() << "Successfully staged and committed! ID:" << git_oid_tostr_s(&commitId);
    return {};
}

QString GitClient::toString(FileStatus status)
{
    switch (status) {
    case FileStatus::Added:
        return "added";
    case FileStatus::Deleted:
        return "deleted";
    case FileStatus::Modified:
        return "modified";
    case FileStatus::Renamed:
        return "renamed";
    case FileStatus::Untracked:
        return "untracked";
    }
    return "unknown";
}
