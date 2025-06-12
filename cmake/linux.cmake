target_link_libraries(${PROJECT_NAME} PRIVATE -lqtcsv)

if (CMAKE_BUILD_TYPE MATCHES "^[Rr]el")

    set(CPACK_GENERATOR "DEB")
    set(CPACK_DEBIAN_PACKAGE_SECTION "finance")  # or appropriate section
    set(CPACK_DEBIAN_PACKAGE_PRIORITY "optional")
    set(CPACK_DEBIAN_ARCHITECTURE ${CMAKE_SYSTEM_PROCESSOR})

    set(CPACK_INSTALL_PREFIX "/opt/${CPACK_PACKAGE_NAME}")
    set(CPACK_PACKAGING_INSTALL_PREFIX "${CPACK_INSTALL_PREFIX}")
    set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY OFF)

    set(CPACK_PACKAGE_FILE_NAME "${CPACK_PACKAGE_NAME}-${CPACK_PACKAGE_VERSION}-Ubuntu")

    install(TARGETS ${PROJECT_NAME} RUNTIME DESTINATION ${CPACK_INSTALL_PREFIX}/bin)

    set(QT_LIB_PATH "${CMAKE_PREFIX_PATH}/lib")
    set(QT_PLUGIN_PATH "${CMAKE_PREFIX_PATH}/plugins")
    set(QT_QML_PATH "${CMAKE_PREFIX_PATH}/qml")
    set(QT_ICU_LIB_MAJOR "73")
    set(QT_ICU_LIB_MINOR "2")

    set(QT_LIBS Charts ChartsQml
        DataVisualization DataVisualizationQml
        EglFSDeviceIntegration EglFsKmsGbmSupport EglFsKmsSupport
        Graphs MultimediaQuick
        OpenGL OpenGLWidgets
        Qml QmlMeta QmlModels QmlWorkerScript
        Quick Quick3D Quick3DRuntimeRender Quick3DUtils QuickControls2
        QuickControls2Basic QuickControls2BasicStyleImpl QuickControls2FluentWinUI3StyleImpl
        QuickControls2Fusion QuickControls2FusionStyleImpl QuickControls2Imagine
        QuickControls2ImagineStyleImpl QuickControls2Impl QuickControls2Material
        QuickControls2MaterialStyleImpl QuickControls2Universal QuickControls2UniversalStyleImpl
        QuickEffects QuickLayouts QuickShapes QuickTemplates2
        ShaderTools
        WaylandClient WaylandEglClientHwIntegration
        Widgets XcbQpa
    )
    foreach(LIB IN LISTS QT_LIBS)
        install(FILES ${QT_LIB_PATH}/libQt6${LIB}.so.6 DESTINATION ${CPACK_INSTALL_PREFIX}/lib)
        install(FILES ${QT_LIB_PATH}/libQt6${LIB}.so.${Qt6_VERSION} DESTINATION ${CPACK_INSTALL_PREFIX}/lib)
    endforeach()

    set(QT_OTHER_LIBS
        icudata.so.${QT_ICU_LIB_MAJOR}
        icudata.so.${QT_ICU_LIB_MAJOR}.${QT_ICU_LIB_MINOR}
        icui18n.so.${QT_ICU_LIB_MAJOR}
        icui18n.so.${QT_ICU_LIB_MAJOR}.${QT_ICU_LIB_MINOR}
        icuuc.so.${QT_ICU_LIB_MAJOR}
        icuuc.so.${QT_ICU_LIB_MAJOR}.${QT_ICU_LIB_MINOR}
    )
    foreach(LIB IN LISTS QT_OTHER_LIBS)
        install(FILES ${QT_LIB_PATH}/lib${LIB} DESTINATION ${CPACK_INSTALL_PREFIX}/lib)
    endforeach()

    set (QML_DIRS
        QML
        QtDataVisualization
        QtGraphs
        QtMultimedia
        QtQml
        QtQml/Models
        QtQml/WorkerScript
        QtQuick
        QtQuick/Controls
        QtQuick/Controls/Basic
        QtQuick/Controls/FluentWinUI3
        QtQuick/Controls/Fusion
        QtQuick/Controls/Imagine
        QtQuick/Controls/Material
        QtQuick/Controls/Universal
        QtQuick/Effects
        QtQuick/Layouts
        QtQuick/Shapes
        QtQuick/Templates
        QtQuick/Window
        QtQuick/LocalStorage
        QtQuick3D
    )
    foreach(DIR IN LISTS QML_DIRS)
        install(DIRECTORY ${QT_QML_PATH}/${DIR} DESTINATION ${CPACK_INSTALL_PREFIX}/qml)
    endforeach()

    set(QT_LIBS Gui Core Multimedia Network SerialPort Sql Svg WebSockets Bluetooth Concurrent DBus)
    foreach(LIB IN LISTS QT_LIBS)
        install(FILES ${QT_LIB_PATH}/libQt6${LIB}.so.6 DESTINATION ${CPACK_INSTALL_PREFIX}/lib)
        install(FILES ${QT_LIB_PATH}/libQt6${LIB}.so.${Qt6_VERSION} DESTINATION ${CPACK_INSTALL_PREFIX}/lib)
    endforeach()

    set(PLUGIN_DIRS egldeviceintegrations generic iconengines imageformats multimedia
                    networkinformation platforminputcontexts
                    platforms platformthemes qmltooling sqldrivers tls xcbglintegrations)
    foreach(DIR IN LISTS PLUGIN_DIRS)
        install(DIRECTORY ${QT_PLUGIN_PATH}/${DIR} DESTINATION ${CPACK_INSTALL_PREFIX}/plugins)
    endforeach()

    install(DIRECTORY ${CMAKE_PREFIX_PATH}/translations DESTINATION ${CPACK_INSTALL_PREFIX})

endif()
