cmake_minimum_required(VERSION 3.27)
project(EvidentaFiscala VERSION 1.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CPACK_PACKAGE_VENDOR "Bogdan Cristea")

include(cmake/internal_utils.cmake)
get_app_version(SW_VERSION "${PROJECT_VERSION}")

configure_file(${CMAKE_SOURCE_DIR}/src/config.h.cmake ${CMAKE_BINARY_DIR}/config.h)

find_package(Qt6 COMPONENTS Core Quick Charts LinguistTools REQUIRED)

include(ExternalProject)
ExternalProject_Add(qtcsv
  GIT_REPOSITORY https://github.com/iamantony/qtcsv.git
  GIT_TAG        v1.7
  SOURCE_DIR    ${CMAKE_BINARY_DIR}/qtcsv_src
  LIST_SEPARATOR |
  CMAKE_ARGS ${ADDITIONAL_CMAKE_ARGS} -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH} -DBUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/qtcsv_install
  STEP_TARGETS   build)

file(GLOB SRCS src/*.cpp src/*.h)

file(GLOB TR_SRCS qml/*.qml src/*.cpp src/*.h)
qt_standard_project_setup(I18N_TRANSLATED_LANGUAGES en fr)
qt_add_translations(TARGETS ${PROJECT_NAME}
                    SOURCES ${TR_SRCS}
                    TS_FILES langs/fr.ts langs/en.ts
                    RESOURCE_PREFIX "/langs")

if (APPLE)
    include(cmake/macos.cmake)
elseif (WIN32)
    include(cmake/windows.cmake)
endif ()

add_dependencies(${PROJECT_NAME} qtcsv)
target_include_directories(${PROJECT_NAME} PRIVATE
    src
    ${CMAKE_BINARY_DIR}
    ${CMAKE_BINARY_DIR}/qtcsv_install/include)
target_link_directories(${PROJECT_NAME} PRIVATE ${CMAKE_BINARY_DIR}/qtcsv_install/lib)

target_compile_definitions(${PROJECT_NAME} PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)

if (CMAKE_BUILD_TYPE MATCHES "^[Rr]elease")
    include(CPack)
endif ()
