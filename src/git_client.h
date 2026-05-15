#pragma once

#include <QStringList>
#include <QPointer>
#include <expected>

struct git_repository;
class GitClient;
class Settings;

void appendToFileList(GitClient* self, const QString& path, uint8_t status);

class GitClient final
{
public:
    enum FileStatus : uint8_t {
        Added = 1,
        Deleted = 1 << 1,
        Modified = 1 << 2,
        Renamed = 1 << 3,
        Untracked = 1 << 4
    };

    enum class RepoStatus {
        Created,
        AlreadyCreated,
    };

    explicit GitClient(Settings const* settings);
    ~GitClient();

    std::expected<RepoStatus,QString> initRepo();
    std::expected<void,QString> openRepo();
    QStringList const& filesWithStatus(uint8_t status);
    std::expected<void,QString> stageAndCommit(QString const& filePath, QString const& commitMessage);

    static QString toString(uint8_t status);
private:
    QPointer<Settings const> const  _settings;
    QStringList _files;
    uint8_t _fileStatus{};
    git_repository* _repo{};

    friend
    void appendToFileList(GitClient* self, const QString& path, uint8_t status);
};
