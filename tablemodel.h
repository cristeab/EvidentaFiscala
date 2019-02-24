#pragma once

#include <QAbstractTableModel>
#include <QStringList>

namespace QtCharts {
    class QAbstractSeries;
    class QXYSeries;
}

class TableModel : public QAbstractTableModel
{
    Q_OBJECT
    Q_PROPERTY(QStringList tableHeader MEMBER _tableHeader CONSTANT)
    Q_PROPERTY(QStringList currencyModel MEMBER _currencyModel CONSTANT)
    Q_PROPERTY(QStringList typeModel MEMBER _typeModel CONSTANT)
    Q_PROPERTY(int xAxisMin MEMBER _xAxisMin NOTIFY xAxisMinChanged)
    Q_PROPERTY(int xAxisMax MEMBER _xAxisMax NOTIFY xAxisMaxChanged)
public:
    enum CourveType { GROSS_INCOME_CURVE = 0, EXPENSE_CURVE, NET_INCOME_CURVE,
                    CURVE_COUNT };
    Q_ENUM(CourveType)
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
    Q_INVOKABLE void setChartSeries(int index, QtCharts::QAbstractSeries *series);
signals:
    void error(const QString &msg, bool fatal = false);
    void xAxisMinChanged();
    void xAxisMaxChanged();
private:
    enum ColumnNames {
        Date = Qt::DisplayRole,
        BankIncome,
        CashIncome,
        BankExpenses,
        CashExpenses,
        InvoiceNumber,
        Observations
    };
    void init();
    QString computeActualAmount(qreal amount, int currencyIndex, qreal rate);
    QString toString(qreal num);
    void initInvoiceNumber();
    bool parseRow(const QStringList &row, int &key, double &income,
                  double &expense);
    void initIncomeCourves();
    void updateIncomeCourves(const QStringList &row);
    void setXAxisMax(int val);

    uint32_t _invoiceNumber = 0;
    const QStringList _tableHeader;
    QStringList _typeModel;
    const QStringList _currencyModel;
    QString _fileName;
    QList<QStringList> _readData;
    const QString _csvSeparator;
    QtCharts::QXYSeries *_chartSeries[CURVE_COUNT];
    int _xAxisMin = 0;
    int _xAxisMax = 1;
    struct MonthlyData {
        MonthlyData(double i, double e) : income(i), expense(e) {}
        MonthlyData() = default;
        double income = 0;
        double expense = 0;
    };
    QMap<int, MonthlyData> _monthlyData;
};
