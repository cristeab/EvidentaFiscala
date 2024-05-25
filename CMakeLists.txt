cmake_minimum_required(VERSION 3.27)
project(EvidentaFiscala VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_MACOSX_RPATH 1)
set(CPACK_PACKAGE_VENDOR "Bogdan Cristea")

include(cmake/internal_utils.cmake)
get_app_version(SW_VERSION "1.0")

configure_file(${CMAKE_SOURCE_DIR}/src/config.h.cmake ${CMAKE_BINARY_DIR}/config.h)

find_package(Qt6 COMPONENTS Core Quick Charts LinguistTools REQUIRED)

include(ExternalProject)
ExternalProject_Add(qtcsv
  GIT_REPOSITORY https://github.com/iamantony/qtcsv.git
  GIT_TAG        v1.7
  SOURCE_DIR    ${CMAKE_BINARY_DIR}/qtcsv_src
  CMAKE_ARGS -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH} -DBUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/qtcsv_install
  STEP_TARGETS   build)

file(GLOB SRCS src/*.cpp src/*.h)

file(GLOB TR_SRCS qml/*.qml src/*.cpp src/*.h)
qt_standard_project_setup(I18N_TRANSLATED_LANGUAGES en fr)
qt_add_translations(TARGETS ${PROJECT_NAME}
                    SOURCES ${TR_SRCS}
                    TS_FILES langs/fr.ts langs/en.ts
                    RESOURCE_PREFIX "/langs")

if (APPLE)
    add_executable(${PROJECT_NAME} MACOSX_BUNDLE ${SRCS} "qml.qrc"
        "${CMAKE_SOURCE_DIR}/img/${PROJECT_NAME}.icns")
elseif (WIN32)
    add_executable(${PROJECT_NAME} WIN32 ${SRCS} "qml.qrc"
        "${CMAKE_SOURCE_DIR}/img/app.rc")
endif ()

add_dependencies(${PROJECT_NAME} qtcsv)
target_include_directories(${PROJECT_NAME} PRIVATE
    src
    ${CMAKE_BINARY_DIR}
    ${CMAKE_BINARY_DIR}/qtcsv_install/include)
target_link_directories(${PROJECT_NAME} PRIVATE ${CMAKE_BINARY_DIR}/qtcsv_install/lib)
set_source_files_properties ("${CMAKE_SOURCE_DIR}/img/${PROJECT_NAME}.icns"
    PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")
set_target_properties(${PROJECT_NAME} PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER "com.cristeab.finance"
    MACOSX_BUNDLE_INFO_STRING "Evidenta Fiscala"
    MACOSX_BUNDLE_ICON_FILE "${PROJECT_NAME}.icns"
    MACOSX_BUNDLE_BUNDLE_NAME "Evidenta Fiscala"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "${PROJECT_VERSION}"
    MACOSX_BUNDLE_BUNDLE_VERSION "${PROJECT_VERSION}"
    MACOSX_BUNDLE_COPYRIGHT "Copyright 2023, Bogdan Cristea. All rights reserved"
    MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist)

target_compile_definitions(${PROJECT_NAME} PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
if (APPLE)
    target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::Core Qt6::Quick Qt6::Charts -lqtcsv)
elseif (WIN32)
    target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::Core Qt6::Quick Qt6::Charts qtcsv.lib)
endif()

if (CMAKE_BUILD_TYPE MATCHES "^[Rr]elease")
    add_custom_target(pack COMMAND ${CMAKE_PREFIX_PATH}/bin/macdeployqt ${CMAKE_PROJECT_NAME}.app -qmldir=${CMAKE_SOURCE_DIR} -libpath=${CMAKE_BINARY_DIR}/qtcsv_install/lib -no-strip -dmg)
    include(CPack)
endif()
