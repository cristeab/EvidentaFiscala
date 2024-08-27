#include "tablemodel.h"
#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QTranslator>

static
QString languageFilePath(int languageIndex)
{
    enum class Language : int { RO, EN, FR };
    switch (static_cast<Language>(languageIndex)) {
    case Language::EN:
	return ":/langs/en";
    case Language::FR:
	return ":/langs/fr";
    default:;
    }
    return {};
}

static
bool loadTranslatorFromSettings (const Settings *settings, QTranslator &translator)
{
    const auto& langFile = languageFilePath(settings->languageIndex());
    bool ok = false;
    if (!langFile.isEmpty() && translator.load(langFile)) {
	ok = QCoreApplication::installTranslator(&translator);
    }
    if (!ok && !langFile.isEmpty()) {
	qWarning() << "Cannot install translator" << langFile;
    }
    if (!ok && langFile.isEmpty()) {
	ok = true;
    }
    return ok;
}

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    qSetMessagePattern("%{appname} [%{threadid}] [%{type}] %{message} (%{file}:%{line})");

    QQmlApplicationEngine engine;
    qmlRegisterType<TableModel>("TableModel", 1, 0, "TableModel");

    const auto importPaths = engine.importPathList();
    for (const auto &path : importPaths) {
	qDebug() << "Import Path:" << path;
    }

    QTranslator translator;

    QQmlContext *context = engine.rootContext();
    if (nullptr != context) {
        auto tableModel = QPointer(new TableModel());
        context->setContextProperty(tableModel->objectName(), tableModel);
	auto* settings = tableModel->settings();
	context->setContextProperty(settings->objectName(), settings);

	// load translator from settings
	loadTranslatorFromSettings(settings, translator);

	QObject::connect(settings, &Settings::languageIndexChanged, &engine,
			 [&engine, &translator, settings]() {
	    if (!translator.isEmpty()) {
		QCoreApplication::removeTranslator(&translator);
	    }
	    if (loadTranslatorFromSettings(settings, translator)) {
		engine.retranslate();
	    }
	});
    }

    engine.load(QUrl(QStringLiteral("qrc:/qml/main.qml")));
    if (engine.rootObjects().isEmpty()) {
        return EXIT_FAILURE;
    }

    return app.exec();
}
