set(CMAKE_REQUIRED_DEFINITIONS "-D_GNU_SOURCE")

if (CMAKE_BUILD_TYPE MATCHES "^[Rr]el")

    set(CPACK_GENERATOR "DEB")
    set(CPACK_DEBIAN_PACKAGE_MAINTAINER "${CPACK_PACKAGE_CONTACT}")
    set(CPACK_DEBIAN_PACKAGE_SECTION "finance")  # or appropriate section
    set(CPACK_DEBIAN_PACKAGE_PRIORITY "optional")
    set(CPACK_DEBIAN_FILE_NAME DEB-DEFAULT)

    if(CMAKE_SYSTEM_PROCESSOR MATCHES "x86_64|amd64")
        set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "amd64")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "i386|i686")
        set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "i386")
    elseif(CMAKE_SYSTEM_PROCESSOR MATCHES "aarch64|arm64")
        set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "arm64")
    else()
        set(CPACK_DEBIAN_PACKAGE_ARCHITECTURE "${CMAKE_SYSTEM_PROCESSOR}")
    endif()

    string(TOLOWER "${PROJECT_NAME}" CPACK_PACKAGE_NAME)
    set(CPACK_INSTALL_PREFIX "/opt/${CPACK_PACKAGE_NAME}")
    set(CPACK_PACKAGING_INSTALL_PREFIX "${CPACK_INSTALL_PREFIX}")
    set(CPACK_INCLUDE_TOPLEVEL_DIRECTORY OFF)

    # This dynamically discovers system libraries (like glibc, libstdc++) your app needs
    set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS ON)
    # Prevent CPack from generating dependencies for bundled Qt6 libs
    set(CPACK_DEBIAN_PACKAGE_SHLIBDEPS_PRIVATE_DIRS "${CPACK_INSTALL_PREFIX}/lib")
    set(CPACK_PRE_BUILD_SCRIPTS "${CMAKE_SOURCE_DIR}/debian/cleanup_qt.cmake")

    set(CPACK_DEBIAN_PACKAGE_CONTROL_EXTRA
        "${CMAKE_SOURCE_DIR}/debian/postinst"
        "${CMAKE_SOURCE_DIR}/debian/postrm"
    )

    include(cmake/linux-utils.cmake)
    get_ubuntu_version(DETECTED_UBUNTU_VERSION)
    if(NOT DETECTED_UBUNTU_VERSION)
        message(FATAL_ERROR "Only Ubuntu Linux is supported")
    endif()

    set(QT_LIB_PATH "${CMAKE_PREFIX_PATH}/lib")
    set(QT_PLUGIN_PATH "${CMAKE_PREFIX_PATH}/plugins")
    set(QT_QML_PATH "${CMAKE_PREFIX_PATH}/qml")
    set(QT_ICU_LIB_MAJOR "73")
    set(QT_ICU_LIB_MINOR "2")

    set(QT_LIBS
        EglFSDeviceIntegration EglFsKmsGbmSupport EglFsKmsSupport
        Graphs MultimediaQuick
        OpenGL OpenGLWidgets
        Qml QmlMeta QmlModels QmlWorkerScript
        Quick Quick3D Quick3DRuntimeRender Quick3DUtils QuickControls2
        QuickDialogs2 QuickDialogs2QuickImpl QuickDialogs2Utils
        QuickControls2Basic QuickControls2BasicStyleImpl QuickControls2FluentWinUI3StyleImpl
        QuickControls2Fusion QuickControls2FusionStyleImpl QuickControls2Imagine
        QuickControls2ImagineStyleImpl QuickControls2Impl QuickControls2Material
        QuickControls2MaterialStyleImpl QuickControls2Universal QuickControls2UniversalStyleImpl
        QuickEffects QuickLayouts QuickShapes QuickTemplates2
        ShaderTools
        WaylandClient WaylandCompositorIviapplication WaylandCompositorPresentationTime
        WaylandCompositor WaylandCompositorWLShell WaylandCompositorXdgShell WaylandEglCompositorHwIntegration
        Widgets XcbQpa
        VirtualKeyboard VirtualKeyboardSettings VirtualKeyboardQml QmlLocalStorage QuickParticles
        Quick3DHelpers Quick3DHelpersImpl Quick3DEffects QuickShapesDesignHelpers
        Quick3DPhysicsHelpers QuickTimeline QuickVectorImage SpatialAudio Quick3DSpatialAudio
        Quick3DAssetImport QuickVectorImageHelpers
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

    # create desktop entries (should go in /usr/ or /usr/local/)
    set(DESKTOP_FILE FiscalRecords.desktop)
    configure_file(${CMAKE_SOURCE_DIR}/debian/${DESKTOP_FILE}.cmake ${CMAKE_BINARY_DIR}/${CPACK_PACKAGE_NAME}.desktop)
    install(FILES ${CMAKE_BINARY_DIR}/${CPACK_PACKAGE_NAME}.desktop
        DESTINATION share/applications RENAME ${CPACK_PACKAGE_NAME}.desktop)
    install(DIRECTORY ${CMAKE_SOURCE_DIR}/debian/icons DESTINATION share)
    install(FILES ${CMAKE_SOURCE_DIR}/img/logo.png DESTINATION ${CPACK_INSTALL_PREFIX}/${CPACK_PACKAGE_NAME}.png)

endif()
