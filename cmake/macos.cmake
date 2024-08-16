add_executable(${PROJECT_NAME} MACOSX_BUNDLE ${SRCS} "qml.qrc"
    "${CMAKE_SOURCE_DIR}/img/${PROJECT_NAME}.icns")

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

target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::Core Qt6::Quick Qt6::Charts -lqtcsv)

if (CMAKE_BUILD_TYPE MATCHES "^[Rr]elease")
    add_custom_target(package COMMAND ${CMAKE_PREFIX_PATH}/bin/macdeployqt
        ${CMAKE_PROJECT_NAME}.app
        -qmldir=${CMAKE_SOURCE_DIR}
        -libpath=${CMAKE_BINARY_DIR}/qtcsv_install/lib
        -no-strip
        -dmg)
endif()