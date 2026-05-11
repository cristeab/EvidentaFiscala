#pragma once

#include <QObject>

class GitClient : public QObject
{
    Q_OBJECT
public:
    explicit GitClient(QObject *parent = nullptr);
    ~GitClient();

signals:
};
