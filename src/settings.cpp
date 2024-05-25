#include "settings.h"
#include <QStandardPaths>
#include <QSettings>

#define XSTR(a) STR_HELPER(a)
#define STR_HELPER(a) #a

#define GET_SETTING(name) settings.value(XSTR(name), _ ## name)
#define SET_SETTING(name) settings.setValue(XSTR(name), _ ## name)

Settings::Settings(QObject *parent) : QObject{ parent }
{
    setObjectName("settings");
    load();
    connect(this, &Settings::languageIndexChanged, this, [this]() {

    }, Qt::QueuedConnection);
}

void Settings::load()
{
    QSettings settings(ORG_NAME, APP_NAME);
    setMinIncome(GET_SETTING(minIncome).toDouble());

    setCsvFolderPath(GET_SETTING(csvFolderPath).toString());
    if (_csvFolderPath.isEmpty()) {
	setCsvFolderPath(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation));
    }

    setInvoiceNumberStart(GET_SETTING(invoiceNumberStart).toInt());
    setLanguageIndex(GET_SETTING(languageIndex).toInt());
}

void Settings::save()
{
     QSettings settings(ORG_NAME, APP_NAME);
     SET_SETTING(minIncome);
     SET_SETTING(csvFolderPath);
     SET_SETTING(invoiceNumberStart);
     SET_SETTING(languageIndex);
}
