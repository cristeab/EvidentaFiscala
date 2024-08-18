set(CMAKE_MSVC_ARCH x64)
set(VC_REDIST_FILENAME "vc_redist.${CMAKE_MSVC_ARCH}.exe")

add_executable(${PROJECT_NAME} WIN32 ${SRCS} "qml.qrc"
    "${CMAKE_SOURCE_DIR}/img/app.rc")

target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::Core Qt6::Quick Qt6::Charts qtcsv.lib)

if (CMAKE_BUILD_TYPE MATCHES "^[Rr]el")
    set(CPACK_GENERATOR "NSIS64")
    set(CPACK_NSIS_EXECUTABLES_DIRECTORY ".")
    set(CPACK_NSIS_MUI_FINISHPAGE_RUN "${PROJECT_NAME}.exe")
    set(CPACK_PACKAGE_INSTALL_DIRECTORY "${PROJECT_NAME}")
    set(CPACK_NSIS_CONTACT "${CPACK_PACKAGE_CONTACT}")
    set(CPACK_NSIS_INSTALLED_ICON_NAME "${PROJECT_NAME}.exe")
    set(CPACK_NSIS_MUI_ICON "${CMAKE_SOURCE_DIR}/img/EvidentaFiscala.ico")
    set(CPACK_NSIS_MUI_UNIICON "${CMAKE_SOURCE_DIR}/img/EvidentaFiscala.ico")
    set(CPACK_NSIS_ENABLE_UNINSTALL_BEFORE_INSTALL ON)
    set(CPACK_PACKAGE_ICON "${CMAKE_SOURCE_DIR}\\\\img\\\\EvidentaFiscala.bmp")
    set(CPACK_NSIS_URL_INFO_ABOUT "${CPACK_PACKAGE_DESCRIPTION_SUMMARY}")
    set(CPACK_NSIS_EXTRA_INSTALL_COMMANDS "ExecWait '\\\"$INSTDIR\\\\${VC_REDIST_FILENAME}\\\" /install /passive /norestart'
         CreateShortCut \\\"$DESKTOP\\\\${PROJECT_NAME}.lnk\\\" \\\"$INSTDIR\\\\${PROJECT_NAME}.exe\\\" \\\"\\\" \\\"$INSTDIR\\\\EvidentaFiscala.ico\\\"
         CreateShortCut \\\"$SMPROGRAMS\\\\${PROJECT_NAME}.lnk\\\" \\\"$INSTDIR\\\\${PROJECT_NAME}.exe\\\" \\\"\\\" \\\"$INSTDIR\\\\EvidentaFiscala.ico\\\"")
    set(CPACK_NSIS_EXTRA_UNINSTALL_COMMANDS "Delete \\\"$DESKTOP\\\\${PROJECT_NAME}.lnk\\\"
         Delete \\\"$SMPROGRAMS\\\\${PROJECT_NAME}.lnk\\\"")

    install(PROGRAMS "${CMAKE_SOURCE_DIR}/build/${PROJECT_NAME}.exe" DESTINATION .)
    install(FILES ${CMAKE_SOURCE_DIR}/img/EvidentaFiscala.ico DESTINATION .)
    install(FILES ${CMAKE_BINARY_DIR}/qtcsv_install/bin/qtcsv.dll DESTINATION .)

    find_program(WINDEPLOYQT windeployqt PATHS ${CMAKE_PREFIX_PATH}/bin/)
    add_custom_target(windeployqt ALL
        COMMAND ${WINDEPLOYQT}
        --dir ${PROJECT_BINARY_DIR}/deploy
        --release
        --compiler-runtime
        --qmldir ${PROJECT_SOURCE_DIR}/qml
        ${PROJECT_NAME}.exe
        DEPENDS ${PROJECT_NAME}.exe
        COMMENT "Preparing Qt runtime dependencies")
    install(DIRECTORY ${PROJECT_BINARY_DIR}/deploy/ DESTINATION .)
endif()
