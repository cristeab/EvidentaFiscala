# Getting Started

Building the project requires a C++ compiler with C++23 standard support.

The build system is based on CMake, which automatically manages the required 
third-party dependencies: QtCSV and libgit2.

# Supported Platforms

- macOS

- Windows

- Linux

# External Dependences

- Qt v6.11.1

- CMake v3.27

- [QtCSV](https://github.com/iamantony/qtcsv.git) v1.7

- [libgit2](https://github.com/libgit2/libgit2.git) v1.9.3

# Installer Generation

Release builds and installer packages can be generated using the provided platform-specific scripts.

## macOS

```bash
./build-macos-release.sh
```

## Windows

```bash
build-win-release.bat
```
