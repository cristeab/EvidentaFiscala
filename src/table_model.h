#pragma once

#include "qmlhelpers.h"
#include <QAbstractTableModel>
#include <QStringList>
#include <expected>

class Settings;
class UiController;

class TableModel : public QAbstractTableModel
{
    Q_OBJECT

    QML_CONSTANT_PROPERTY(QStringList, tableHeader, {})

    QML_CONSTANT_PROPERTY(QStringList, currencyModel, {})
    QML_WRITABLE_PROPERTY(int, currencyModelIndex, setCurrencyModelIndex, 0)

    QML_READABLE_PROPERTY(QStringList, transactionTypeModel, setTransactionTypeModel, {})
    QML_READABLE_PROPERTY(int, defaultTransactionTypeModelIndex, setDefaultTransactionTypeModelIndex, 2)

    QML_READABLE_PROPERTY(int, suggestionMaxLength, setSuggestionMaxLength, 0)
    QML_READABLE_PROPERTY(QString, errorMessage, setErrorMessage, {})

public:
    enum ColumnIndex {
        DATE_INDEX = 0,
        BANK_INCOME_INDEX,
        CASH_INCOME_INDEX,
        BANK_EXPENSES_INDEX,
        CASH_EXPENSES_INDEX,
        INVOICE_NUMBER_INDEX,
        COMMENTS_INDEX,
        COLUMN_COUNT
    };
    Q_ENUM(ColumnIndex)

    struct MonthlyData {
        qreal income{};
        qreal expense{};
    };

    explicit TableModel(UiController* controller);

    void openLedger(const QString &fileName);
    int rowCount(const QModelIndex & = QModelIndex()) const override {
        return _readData.size();
    }
    int columnCount(const QModelIndex & = QModelIndex()) const override {
        return _tableHeader.size();
    }
    QVariant data(const QModelIndex &index, int role) const override;
    QHash<int, QByteArray> roleNames() const override;
    Q_INVOKABLE bool add(const QString &date, int typeIndex, qreal amount,
                         int currencyIndex, qreal rate, const QString &obs);

    Q_INVOKABLE bool updateInvisibleColumns(const QList<int> &indexList);
    Q_INVOKABLE bool isColumnVisible(int index) const;

    Q_INVOKABLE QStringList suggestions(QString input);

    constexpr QString const& currentCurrency() const {
        return _currencyModel.at(_currencyModelIndex);
    }

    constexpr bool isEmpty() const {
        return _monthlyData.isEmpty();
    }

    MonthlyData total() const;
    QString year() const;
    constexpr auto monthlyData() const {
        return _monthlyData.asKeyValueRange();
    }
    constexpr auto size() const {
        return _monthlyData.size();
    }

    [[nodiscard]] static QString toString(qreal num);

    void initMonthlyData();
    void updateMonthlyData(int rowIndex);
    void sortRows();

signals:
    void error(const QString &msg, bool fatal);

private:
    enum ColumnNames {
        Date = Qt::DisplayRole,
        BankIncome,
        CashIncome,
        BankExpenses,
        CashExpenses,
        InvoiceNumber,
        Comments
    };

    void init();
    [[nodiscard]]
    QString computeActualAmount(qreal amount, int currencyIndex, qreal rate) const;
    void initInvoiceNumber();
    bool parseRow(int rowIndex, QDateTime &key, qreal &income, qreal &expense);

    static bool ensureLastCharIsNewLine(const QString& filePath);
    void updateTypeModel();

    [[nodiscard]]
    bool isIncome(int typeIndex) const;

    [[nodiscard]]
    std::expected<void,QString> isValidRow(QStringList const& row);

    const static QLocale _locale;
    const static QString _csvSeparator;
    const static QStringList _dateFormats;

    uint32_t _invoiceNumber{};
    QList<QStringList> _readData;
    QMap<QDateTime, MonthlyData> _monthlyData;
    UiController& _controller;
};
