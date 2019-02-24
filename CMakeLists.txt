cmake_minimum_required(VERSION 3.1)

project(EvidentaFiscala LANGUAGES CXX)

set(CMAKE_INCLUDE_CURRENT_DIR ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Qt5 COMPONENTS Core Quick Charts REQUIRED)

include_directories(${PROJECT_SOURCE_DIR}/../qtcsv_install/include)
link_directories(${PROJECT_SOURCE_DIR}/../qtcsv_install/lib)

file(GLOB SRCS *.cpp)

add_executable(${PROJECT_NAME} MACOSX_BUNDLE "${SRCS}" "qml.qrc"
    "${CMAKE_SOURCE_DIR}/img/${PROJECT_NAME}.icns")
set_source_files_properties ("${CMAKE_SOURCE_DIR}/img/${PROJECT_NAME}.icns"
        PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")
    set_target_properties(${PROJECT_NAME} PROPERTIES
        MACOSX_BUNDLE_INFO_STRING "Evidenta Fiscala"
        MACOSX_BUNDLE_ICON_FILE "${PROJECT_NAME}.icns"
        MACOSX_BUNDLE_BUNDLE_NAME "Evidenta Fiscala"
        MACOSX_BUNDLE_SHORT_VERSION_STRING "0.1"
        MACOSX_BUNDLE_BUNDLE_VERSION "0.1"
        MACOSX_BUNDLE_COPYRIGHT "Copyright 2019, Bogdan Cristea. All rights reserved")

target_compile_definitions(${PROJECT_NAME} PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt5::Core Qt5::Quick Qt5::Charts -lqtcsv)

if (CMAKE_BUILD_TYPE MATCHES "^[Rr]elease")
    add_definitions(-DRELEASE_FOLDER)
    add_custom_target(pack COMMAND ${CMAKE_PREFIX_PATH}/bin/macdeployqt ${CMAKE_PROJECT_NAME}.app -qmldir=${CMAKE_SOURCE_DIR} -no-strip -dmg)
    include(CPack)
endif()
