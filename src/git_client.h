#pragma once

#include <QObject>
#include <QStringList>

struct git_repository;

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

    explicit GitClient(const QString& path, QObject *parent = nullptr);
    ~GitClient();

    QStringList const& filesWithStatus(FileStatus status);
    bool stageAndCommit(QString const& filePath, QString const& commitMessage);

    void appendToFileList(const QString& path, FileStatus status) {
        if (status == _fileStatus) {
            _files.append(path);
        }
    }

private:
    QStringList _files;
    FileStatus _fileStatus{};

    git_repository* _repo{};
};
