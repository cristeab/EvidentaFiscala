# Getting Started

To compile a C++ compiler supporting C++23 standard is needed. The compilation is
managed by cmake such that the external libraries (qtcsv, libgit2) are handled by cmake.

# Supported Platforms

- macOS

- Windows

- Linux (planned)

# External Dependences:

- Qt v6.11.1

- cmake v3.27

- qtcsv v1.7 (https://github.com/iamantony/qtcsv.git)

- libgit2 v1.9.3 (https://github.com/libgit2/libgit2.git)

# Installer Generation

- use the provided script to compile and generate the installer:

On macOS:

    ./build-macos-release.sh

On Windows:

    build-win-release.bat
