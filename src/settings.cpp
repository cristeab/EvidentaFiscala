#include "settings.h"
#include <QStandardPaths>
#include <QDate>
#include <QtCore/qfileinfo.h>
#include <QDir>

#define XSTR(a) STR_HELPER(a)
#define STR_HELPER(a) #a

#define GET_SETTING(name) _settings.value(XSTR(name), _ ## name)
#define SET_SETTING(name) _settings.setValue(XSTR(name), _ ## name)

Settings::Settings(QObject *parent) : _settings(ORG_NAME, APP_NAME), QObject(parent)
{
    setObjectName("settings");
    load();

    connect(this, &Settings::ledgerFilePathChanged, this, [this]() {
	    SET_SETTING(ledgerFilePath);
    }, Qt::QueuedConnection);
}

void Settings::load()
{
    setMinIncome(GET_SETTING(minIncome).toDouble());

    setWorkingFolderPath(GET_SETTING(workingFolderPath).toString());
    if (_workingFolderPath.isEmpty()) {
	setWorkingFolderPath(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation));
    }

    setLedgerFilePath(GET_SETTING(ledgerFilePath).toString());
    if (_ledgerFilePath.isEmpty()) {
	const auto ledgerFileName = QString("ledger_pfa_%1.csv").arg(QDate::currentDate().year());
	QDir dir(_workingFolderPath);
	setLedgerFilePath(dir.filePath(ledgerFileName));
    }

    setInvoiceNumberStart(GET_SETTING(invoiceNumberStart).toInt());
    setLanguageIndex(GET_SETTING(languageIndex).toInt());
}

void Settings::save()
{
    SET_SETTING(minIncome);
    SET_SETTING(workingFolderPath);
    SET_SETTING(invoiceNumberStart);
    SET_SETTING(languageIndex);
}
