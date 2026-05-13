#pragma once

#include <QStringList>

struct git_repository;
class GitClient;
class Settings;

void appendToFileList(GitClient* self, const QString& path, int status);

class GitClient
{
public:
    enum class FileStatus {
        Added = (1 << 0),
        Deleted = (1 << 1),
        Modified = (1 << 2),
        Renamed = (1 << 3),
        Untracked = (1 << 4)
    };

    GitClient(QString const& repoPath, Settings const& settings);
    ~GitClient();

    QStringList const& filesWithStatus(FileStatus status);
    bool stageAndCommit(QString const& filePath, QString const& commitMessage);

private:
    Settings const& _settings;
    QStringList _files;
    FileStatus _fileStatus{};
    git_repository* _repo{};

    friend
    void appendToFileList(GitClient* self, const QString& path, int status);
};
