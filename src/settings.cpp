#include "settings.h"
#include <QStandardPaths>

#define XSTR(a) STR_HELPER(a)
#define STR_HELPER(a) #a

#define GET_SETTING(name) _settings.value(XSTR(name), _ ## name)
#define SET_SETTING(name) _settings.setValue(XSTR(name), _ ## name)

Settings::Settings(QObject *parent) : _settings(ORG_NAME, APP_NAME), QObject(parent)
{
    setObjectName("settings");
    load();
}

void Settings::load()
{
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
     SET_SETTING(minIncome);
     SET_SETTING(csvFolderPath);
     SET_SETTING(invoiceNumberStart);
     SET_SETTING(languageIndex);
}
