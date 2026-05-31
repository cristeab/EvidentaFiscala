# This script runs directly inside the CPack packaging tree
message(STATUS "CPack Pre-Build: Purging unused Qt modules from ${CPACK_TEMPORARY_DIRECTORY}...")

# CPack sets CPACK_TEMPORARY_DIRECTORY to point to the real staging root (e.g. ./_CPack_Packages/.../DEB)
set(STAGING_DIR "${CPACK_TEMPORARY_DIRECTORY}/opt/fiscalrecords")

# Physically delete the problematic directories
file(REMOVE_RECURSE "${STAGING_DIR}/plugins/sqldrivers")
file(REMOVE_RECURSE "${STAGING_DIR}/qml/QtQml/StateMachine")
file(REMOVE_RECURSE "${STAGING_DIR}/qml/QtQml/XmlListModel")
file(REMOVE_RECURSE "${STAGING_DIR}/qml/QtQuick/Timeline")
file(REMOVE_RECURSE "${STAGING_DIR}/qml/QtQuick3D")
file(REMOVE_RECURSE "${STAGING_DIR}/plugins/multimedia")
file(REMOVE_RECURSE "${STAGING_DIR}/plugins/imageformats")
