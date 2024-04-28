#include "settings.h"
#include "config.h"
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
}

void Settings::load()
{
    QSettings settings(ORG_NAME, APP_NAME);
    setMinIncome(GET_SETTING(minIncome).toDouble());
    if (0 >= _minIncome) {
	setMinIncome(DEFAULT_MIN_INCOME);
    }
    setCsvFolderPath(GET_SETTING(csvFolderPath).toString());
    if (_csvFolderPath.isEmpty()) {
	setCsvFolderPath(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation));
    }
    setInvoiceNumberStart(GET_SETTING(invoiceNumberStart).toInt());
    if (1 > _invoiceNumberStart) {
	setInvoiceNumberStart(DEFAULT_INVOICE_NUMBER_START);
    }
    setLanguageIndex(GET_SETTING(languageIndex).toInt());
    if (0 > _languageIndex) {
	setLanguageIndex(DEFAULT_LANGUAGE_INDEX);
    }
}

void Settings::save()
{
     QSettings settings(ORG_NAME, APP_NAME);
     SET_SETTING(minIncome);
     SET_SETTING(csvFolderPath);
     SET_SETTING(invoiceNumberStart);
     SET_SETTING(languageIndex);
}
