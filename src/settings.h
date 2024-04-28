#pragma once

#include "qmlhelpers.h"

class Settings : public QObject {
Q_OBJECT
    QML_WRITABLE_PROPERTY_FLOAT(qreal, minIncome, setMinIncome, 1600)
    QML_WRITABLE_PROPERTY(QString, csvFolderPath, setCsvFolderPath, {})
    QML_WRITABLE_PROPERTY(int, invoiceNumberStart, setInvoiceNumberStart, 1)
    QML_WRITABLE_PROPERTY(int, languageIndex, setLanguageIndex, {})
public:
    explicit Settings(QObject *parent = nullptr);

    Q_INVOKABLE void load();
    Q_INVOKABLE void save();
};
