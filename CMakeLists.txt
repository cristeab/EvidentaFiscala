cmake_minimum_required(VERSION 3.27)

project(EvidentaFiscala VERSION 1.0.0 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)

set(CMAKE_MACOSX_RPATH 1)

find_package(Qt6 COMPONENTS Core Quick Charts REQUIRED)

include(ExternalProject)
ExternalProject_Add(qtcsv
  GIT_REPOSITORY https://github.com/iamantony/qtcsv.git
  GIT_TAG        v1.7
  SOURCE_DIR    ${CMAKE_BINARY_DIR}/qtcsv_src
  CMAKE_ARGS -DCMAKE_PREFIX_PATH=${CMAKE_PREFIX_PATH} -DBUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=${CMAKE_BINARY_DIR}/qtcsv_install
  STEP_TARGETS   build)

file(GLOB SRCS src/*.cpp src/*.h)

add_executable(${PROJECT_NAME} MACOSX_BUNDLE "${SRCS}" "qml.qrc"
    "${CMAKE_SOURCE_DIR}/img/${PROJECT_NAME}.icns")
add_dependencies(${PROJECT_NAME} qtcsv)
target_include_directories(${PROJECT_NAME} PRIVATE src ${CMAKE_BINARY_DIR}/qtcsv_install/include)
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
    MACOSX_BUNDLE_COPYRIGHT "Copyright 2019, Bogdan Cristea. All rights reserved"
    MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist)

target_compile_definitions(${PROJECT_NAME} PRIVATE $<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>)
target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::Core Qt6::Quick Qt6::Charts -lqtcsv)

if (CMAKE_BUILD_TYPE MATCHES "^[Rr]elease")
    add_custom_target(pack COMMAND ${CMAKE_PREFIX_PATH}/bin/macdeployqt ${CMAKE_PROJECT_NAME}.app -qmldir=${CMAKE_SOURCE_DIR} -libpath=${CMAKE_BINARY_DIR}/qtcsv_install/lib -no-strip -dmg)
    include(CPack)
endif()
