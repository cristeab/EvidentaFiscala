#pragma once

#include "settings.h"
#include <QAbstractTableModel>
#include <QStringList>
#include <QDateTime>

class QAbstractSeries;
class QXYSeries;

class TableModel : public QAbstractTableModel
{
    Q_OBJECT
    QML_CONSTANT_PROPERTY(QStringList, tableHeader, {})
    QML_CONSTANT_PROPERTY(QStringList, currencyModel, {})
    QML_READABLE_PROPERTY(QStringList, typeModel, setTypeModel, {})
    QML_READABLE_PROPERTY(int, defaultTypeModelIndex, setDefaultTypeModelIndex, 2)
    QML_READABLE_PROPERTY(QDateTime, xAxisMin, setXAxisMin, {})
    QML_READABLE_PROPERTY(QDateTime, xAxisMax, setXAxisMax, {})
    QML_READABLE_PROPERTY(int, xAxisTickCount, setXAxisTickCount, 2)
    QML_READABLE_PROPERTY(qreal, yAxisMin, setYAxisMin, 0)
    QML_READABLE_PROPERTY(qreal, yAxisMax, setYAxisMax, 1)
    QML_CONSTANT_PROPERTY_PTR(Settings, settings)

    QML_READABLE_PROPERTY(QStringList, barMonths, setBarMonths, {})
    QML_READABLE_PROPERTY(QVariantList, barRevenue, setBarRevenue, {})
    QML_READABLE_PROPERTY(QVariantList, barNetIncome, setBarNetIncome, {})

public:
    enum CourveType { GROSS_INCOME_CURVE = 0,
		      EXPENSE_CURVE,
		      NET_INCOME_CURVE,
		      THRESHOLD_CURVE,
		      CURVE_COUNT };
    Q_ENUM(CourveType)

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

    TableModel();
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
    Q_INVOKABLE void setChartSeries(int index, QAbstractSeries *series);
    Q_INVOKABLE void generateRegistry();
    Q_INVOKABLE void openLedger(const QUrl &url);

    Q_INVOKABLE bool isColumnVisible(int index) const {
	return 0 == _settings->_invisibleColumns.count(index);
    }
    Q_INVOKABLE int invisibleColumns() const {
	return static_cast<int>(_settings->_invisibleColumns.size());
    }
    Q_INVOKABLE void setInvisibleColumns(const QList<int> &indexList);

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
    QString computeActualAmount(qreal amount, int currencyIndex, qreal rate);
    static QString toString(qreal num);
    void initInvoiceNumber();
    bool parseRow(int rowIndex, QDateTime &key, qreal &income, qreal &expense);
    void sortRows();

    void initMonthlyData();
    void updateMonthlyData(int rowIndex);

    void initGraphLines();
    void updateGraphLines(int rowIndex);
    void resetGraphLines();

    void initGraphBars();
    void updateGraphBars(int rowIndex);
    void resetGraphBars();

    void updateXAxis(const QDateTime &val);
    void updateYAxis(qreal amount);

    static bool ensureLastCharIsNewLine(const QString& filePath);
    void resetMinIncome();
    void updateTypeModel();

    bool isIncome(int typeIndex) const;

    const static QLocale _locale;
    uint32_t _invoiceNumber{};
    QList<QStringList> _readData;
    const QString _csvSeparator;
    std::array<QXYSeries*, CURVE_COUNT> _chartSeries;
    struct MonthlyData {
        qreal income{};
        qreal expense{};
    };
    QMap<QDateTime, MonthlyData> _monthlyData;
    const QStringList _dateFormats;
};
