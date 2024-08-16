add_executable(${PROJECT_NAME} WIN32 ${SRCS} "qml.qrc"
    "${CMAKE_SOURCE_DIR}/img/app.rc")

target_link_libraries(${PROJECT_NAME} PRIVATE Qt6::Core Qt6::Quick Qt6::Charts qtcsv.lib)
