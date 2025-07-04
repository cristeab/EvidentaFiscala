#pragma once

#include "qmlhelpers.h"
#include "config.h"
#include <QSettings>
#include <unordered_set>

class TableModel;

class Settings : public QObject {
Q_OBJECT
public:
    static constexpr qreal DEFAULT_MIN_INCOME{2000};
    static constexpr int DEFAULT_INVOICE_NUMBER_START{1};
    static constexpr int DEFAULT_LANGUAGE_INDEX{0};

    QML_CONSTANT_PROPERTY(QString, swVersion, APP_VERSION)
    QML_WRITABLE_PROPERTY_FLOAT(qreal, minIncome, setMinIncome, DEFAULT_MIN_INCOME)
    QML_WRITABLE_PROPERTY(QString, workingFolderPath, setWorkingFolderPath, {})
    QML_WRITABLE_PROPERTY(QString, ledgerFilePath, setLedgerFilePath, {})
    QML_WRITABLE_PROPERTY(int, invoiceNumberStart, setInvoiceNumberStart, DEFAULT_INVOICE_NUMBER_START)
    QML_WRITABLE_PROPERTY(int, languageIndex, setLanguageIndex, DEFAULT_LANGUAGE_INDEX)

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
