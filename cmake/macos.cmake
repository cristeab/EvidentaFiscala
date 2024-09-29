set(BUNDLE_ID "com.cristeab.fiscalrecords")

set(CMAKE_MACOSX_RPATH TRUE)

target_sources(${PROJECT_NAME} PRIVATE "${CMAKE_SOURCE_DIR}/img/logo.icns")

set_source_files_properties ("${CMAKE_SOURCE_DIR}/img/logo.icns"
    PROPERTIES MACOSX_PACKAGE_LOCATION "Resources")
set_target_properties(${PROJECT_NAME} PROPERTIES
    MACOSX_BUNDLE TRUE
    MACOSX_BUNDLE_GUI_IDENTIFIER ${BUNDLE_ID}
    MACOSX_BUNDLE_INFO_STRING "Fiscal Records"
    MACOSX_BUNDLE_ICON_FILE "logo.icns"
    MACOSX_BUNDLE_BUNDLE_NAME "Fiscal Records"
    MACOSX_BUNDLE_SHORT_VERSION_STRING "${PROJECT_VERSION}"
    MACOSX_BUNDLE_BUNDLE_VERSION "${PROJECT_VERSION}"
    MACOSX_BUNDLE_COPYRIGHT "Copyright 2023, Bogdan Cristea. All rights reserved"
    MACOSX_BUNDLE_INFO_PLIST ${CMAKE_CURRENT_SOURCE_DIR}/Info.plist)

target_link_libraries(${PROJECT_NAME} PRIVATE
    -lqtcsv)

if (CMAKE_BUILD_TYPE MATCHES "^[Rr]el")
    find_program(MACDEPLOYQT macdeployqt HINTS "${_qt_bin_dir}")
    add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${MACDEPLOYQT} $<TARGET_BUNDLE_DIR:${PROJECT_NAME}>
        -qmldir=${CMAKE_SOURCE_DIR}
        -libpath=${CMAKE_BINARY_DIR}/qtcsv_install/lib
        -no-strip
        -always-overwrite
        COMMENT "Running macdeployqt...")

    set(CPACK_GENERATOR "productbuild")
    set(CPACK_PRODUCTBUILD_IDENTIFIER ${BUNDLE_ID})
    set(CPACK_PACKAGE_FILE_NAME "${PROJECT_NAME}-${SW_VERSION}")
    set(CPACK_OSX_PACKAGE_VERSION "11")
endif()
