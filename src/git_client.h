#pragma once

#include <QObject>
#include <QStringList>

struct git_repository;
class GitClient;

void appendToFileList(GitClient* self, const QString& path, int status);

class GitClient : public QObject
{
    Q_OBJECT
public:
    enum class FileStatus {
        Added = (1 << 0),
        Deleted = (1 << 1),
        Modified = (1 << 2),
        Renamed = (1 << 3),
        Untracked = (1 << 4)
    };

    explicit GitClient(const QString& repoPath, QObject *parent = nullptr);
    ~GitClient();

    QStringList const& filesWithStatus(FileStatus status);
    bool stageAndCommit(QString const& filePath, QString const& commitMessage);

private:
    QStringList _files;
    FileStatus _fileStatus{};

    git_repository* _repo{};

    friend
    void appendToFileList(GitClient* self, const QString& path, int status);
};
