#include "tablemodel.h"
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>

int main(int argc, char *argv[])
{
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QApplication app(argc, argv);
    qSetMessagePattern("%{appname} [%{threadid}] [%{type}] %{message} (%{file}:%{line})");

    QQmlApplicationEngine engine;
    qmlRegisterType<TableModel>("TableModel", 1, 0, "TableModel");

    QQmlContext *context = engine.rootContext();
    if (nullptr != context) {
        TableModel *tableModel = new TableModel();
        context->setContextProperty(tableModel->objectName(), tableModel);
    }

    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
