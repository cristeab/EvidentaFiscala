#include "git_client.h"
#include "git2.h"

GitClient::GitClient(QObject *parent)
    : QObject{parent}
{
    git_libgit2_init();
}

GitClient::~GitClient()
{
    git_libgit2_shutdown();
}
