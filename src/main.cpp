#include "tablemodel.h"
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    qSetMessagePattern("%{appname} [%{threadid}] [%{type}] %{message} (%{file}:%{line})");

    QQmlApplicationEngine engine;
    qmlRegisterType<TableModel>("TableModel", 1, 0, "TableModel");

    QQmlContext *context = engine.rootContext();
    if (nullptr != context) {
        auto tableModel = QPointer(new TableModel());
        context->setContextProperty(tableModel->objectName(), tableModel);
    }

    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return EXIT_FAILURE;
    }

    return app.exec();
}
