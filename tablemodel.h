#pragma once

#include <QAbstractTableModel>
#include <QStringList>
#include <QDateTime>

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
    Q_PROPERTY(QDateTime xAxisMin MEMBER _xAxisMin NOTIFY xAxisMinChanged)
    Q_PROPERTY(QDateTime xAxisMax MEMBER _xAxisMax NOTIFY xAxisMaxChanged)
    Q_PROPERTY(int xAxisTickCount MEMBER _xAxisTickCount NOTIFY xAxisTickCountChanged)
    Q_PROPERTY(qreal yAxisMin MEMBER _yAxisMin NOTIFY yAxisMinChanged)
    Q_PROPERTY(qreal yAxisMax MEMBER _yAxisMax NOTIFY yAxisMaxChanged)
    Q_PROPERTY(QString fileName MEMBER _fileName NOTIFY fileNameChanged)
public:
    enum CourveType { GROSS_INCOME_CURVE = 0, EXPENSE_CURVE, NET_INCOME_CURVE,
                      THRESHOLD_CURVE, CURVE_COUNT };
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
    void xAxisTickCountChanged();
    void yAxisMinChanged();
    void yAxisMaxChanged();
    void fileNameChanged();
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
    enum { THRESHOLD_VALUE = 11112 };
    void init();
    QString computeActualAmount(qreal amount, int currencyIndex, qreal rate);
    static QString toString(qreal num);
    void initInvoiceNumber();
    bool parseRow(int rowIndex, QDateTime &key, qreal &income,
                  qreal &expense);
    void sortRows();
    void initIncomeCourves();
    void updateIncomeCourves(int rowIndex);
    void setXAxisMin(const QDateTime &val);
    void setXAxisMax(const QDateTime &val);
    void updateXAxis(const QDateTime &val);
    void setYAxisMin(qreal val);
    void setYAxisMax(qreal val);
    void updateYAxis(qreal amount);
    void resetCurves();
    void setFileName(const QString &fn);
    void setXAxisTickCount(int count);
    bool ensureLastCharIsNewLine();

    const static QLocale _locale;
    uint32_t _invoiceNumber = 0;
    const QStringList _tableHeader;
    QStringList _typeModel;
    const QStringList _currencyModel;
    QString _fileName;
    QList<QStringList> _readData;
    const QString _csvSeparator;
    QtCharts::QXYSeries *_chartSeries[CURVE_COUNT];
    QDateTime _xAxisMin;
    QDateTime _xAxisMax;
    int _xAxisTickCount = 2;
    qreal _yAxisMin = 0;
    qreal _yAxisMax = 1;
    struct MonthlyData {
        MonthlyData(qreal i, qreal e) : income(i), expense(e) {}
        MonthlyData() = default;
        qreal income = 0;
        qreal expense = 0;
    };
    QMap<QDateTime, MonthlyData> _monthlyData;
    const QStringList _dateFormats;
};
