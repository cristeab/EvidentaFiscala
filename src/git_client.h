#pragma once

#include <QObject>
#include <QStringList>

struct git_repository;

enum class FileStatus {
    Added = (1 << 0),
    Deleted = (1 << 1),
    Modified = (1 << 2),
    Renamed = (1 << 3),
    Untracked = (1 << 4)
};
constexpr FileStatus operator|(FileStatus left, FileStatus right) {
    return static_cast<FileStatus>(static_cast<int>(left) | static_cast<int>(right));
}

constexpr FileStatus operator&(FileStatus left, FileStatus right) {
    return static_cast<FileStatus>(static_cast<int>(left) & static_cast<int>(right));
}


class GitClient : public QObject
{
    Q_OBJECT
public:
    explicit GitClient(const QString& path, QObject *parent = nullptr);
    ~GitClient();

    QStringList const& files(FileStatus status);
    bool stageAndCommit(QString const& filePath, QString const& commitMessage);

    void tryAppendToFileList(const QString& path, FileStatus status) {
        if (status == (status & _fileStatus)) {
            _files.append(path);
        }
    }

private:
    QStringList _files;
    FileStatus _fileStatus{};

    git_repository* _repo{};
};
