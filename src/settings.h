#pragma once

#include "qmlhelpers.h"
#include "config.h"
#include <QSettings>
#include <unordered_set>

class TableModel;

class Settings : public QObject {
Q_OBJECT
public:
    QML_CONSTANT_PROPERTY(QString, swVersion, APP_VERSION)
    QML_WRITABLE_PROPERTY_FLOAT(qreal, minIncome, setMinIncome, 2000)
    QML_WRITABLE_PROPERTY(QString, workingFolderPath, setWorkingFolderPath, {})
    QML_WRITABLE_PROPERTY(QString, ledgerFilePath, setLedgerFilePath, {})
    QML_WRITABLE_PROPERTY(int, invoiceNumberStart, setInvoiceNumberStart, 1)
    QML_WRITABLE_PROPERTY(int, languageIndex, setLanguageIndex, 1)
    QML_WRITABLE_PROPERTY(int, csvHeaderIndex, setCsvHeaderIndex, 0)

    QML_WRITABLE_PROPERTY(bool, useBars, setUseBars, true)

public:
    explicit Settings(QObject *parent = nullptr);

    Q_INVOKABLE void load();
    Q_INVOKABLE void save();

private:
    QSettings _settings;
    std::unordered_set<int> _invisibleColumns;
    friend TableModel;
};
