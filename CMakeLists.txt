cmake_minimum_required(VERSION 3.27)
project(FiscalRecords VERSION 1.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)

set(CPACK_PACKAGE_VENDOR "Bogdan Cristea")

if(APPLE)
    # universal binary for macOS
    set(CMAKE_OSX_ARCHITECTURES "x86_64;arm64")
    set(ADDITIONAL_CMAKE_ARGS -DCMAKE_OSX_ARCHITECTURES:STRING=x86_64|arm64)
endif()

add_executable(${PROJECT_NAME})

include(cmake/internal_utils.cmake)
get_app_version(SW_VERSION "${PROJECT_VERSION}")

configure_file(${CMAKE_SOURCE_DIR}/src/config.h.cmake ${CMAKE_BINARY_DIR}/config.h)

find_package(Qt6 REQUIRED COMPONENTS
    Core
    Quick
    Graphs
    LinguistTools)
target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Core
    Qt6::Quick
    Qt6::Graphs)

# Set up the project with Qt standard configurations
qt_standard_project_setup()

# platform specific code
if(APPLE)
    include(cmake/macos.cmake)
elseif(WIN32)
    include(cmake/windows.cmake)
endif()

include(ExternalProject)
ExternalProject_Add(qtcsv
  GIT_REPOSITORY https://github.com/iamantony/qtcsv.git
  GIT_TAG        v1.7
  SOURCE_DIR    ${CMAKE_BINARY_DIR}/qtcsv_src
  LIST_SEPARATOR |
  CMAKE_ARGS ${ADDITIONAL_CMAKE_ARGS} -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH} -DBUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/qtcsv_install
  STEP_TARGETS   build)

file(GLOB SRCS src/*.cpp)
target_sources(${PROJECT_NAME} PRIVATE ${SRCS})

file(GLOB TR_SRCS qml/*.qml src/*.cpp src/*.h)
qt_standard_project_setup(I18N_TRANSLATED_LANGUAGES en fr)
qt_add_translations(TARGETS ${PROJECT_NAME}
                    SOURCES ${TR_SRCS}
                    TS_FILES langs/fr.ts langs/en.ts
                    RESOURCE_PREFIX "/langs")

# images
set(IMG_FILES img/FolderOpen.svg
              img/FileCsv.svg
              img/Settings.svg
              img/FileExport.svg)

# Enable the Qt Quick Compiler
file(GLOB_RECURSE QML_FILES
    RELATIVE ${CMAKE_SOURCE_DIR}
    ${CMAKE_SOURCE_DIR}/qml/*.qml)

qt_add_qml_module(${PROJECT_NAME}
    URI ${PROJECT_NAME}
    OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qml
    RESOURCE_PREFIX /
    NO_RESOURCE_TARGET_PATH
    VERSION 1.0
    QML_FILES ${QML_FILES}
    RESOURCES qml/qmldir qtquickcontrols2.conf ${IMG_FILES})

add_dependencies(${PROJECT_NAME} qtcsv)
target_include_directories(${PROJECT_NAME} PRIVATE
    src
    ${CMAKE_BINARY_DIR}
    ${CMAKE_BINARY_DIR}/qtcsv_install/include)
target_link_directories(${PROJECT_NAME} PRIVATE ${CMAKE_BINARY_DIR}/qtcsv_install/lib)

target_compile_definitions(${PROJECT_NAME} PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

if (CMAKE_BUILD_TYPE MATCHES "^[Rr]el")
    install(TARGETS ${PROJECT_NAME}
        BUNDLE DESTINATION .
        RUNTIME DESTINATION .
        COMPONENT ${PROJECT_NAME}
    )

    # make sure the resource files have the right extension
    configure_file("${CMAKE_SOURCE_DIR}/LICENSE" "${CMAKE_BINARY_DIR}/LICENSE.txt" COPYONLY)
    configure_file("${CMAKE_SOURCE_DIR}/README.md" "${CMAKE_BINARY_DIR}/README.txt" COPYONLY)

    set(CPACK_PACKAGE_NAME ${PROJECT_NAME})
    set(CPACK_PACKAGE_DESCRIPTION_SUMMARY "Application for Keeping Fiscal Records")
    set(CPACK_PACKAGE_DESCRIPTION_FILE ${CMAKE_BINARY_DIR}/README.txt)
    set(CPACK_PACKAGE_VERSION ${SW_VERSION})
    set(CPACK_RESOURCE_FILE_README ${CMAKE_BINARY_DIR}/README.txt)
    set(CPACK_RESOURCE_FILE_LICENSE ${CMAKE_BINARY_DIR}/LICENSE.txt)
    set(CPACK_PACKAGE_CONTACT "cristeab@gmail.com")
    set(CPACK_PACKAGE_VENDOR "Bogdan Cristea")
    set(CPACK_STRIP_FILES ${PROJECT_NAME})

    include(CPack)
    # workaround for generating the pkg installer
    cpack_add_component(${PROJECT_NAME})
endif ()
