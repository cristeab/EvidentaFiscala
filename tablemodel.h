#pragma once

#include <QAbstractTableModel>
#include <QStringList>

namespace QtCharts {
    class QAbstractSeries;
}

class TableModel : public QAbstractTableModel
{
    Q_OBJECT
public:
    enum CourveType { GROSS_INCOME_COURVE = 0, EXPENSE_COURVE, NET_INCOME_COURVE,
                    COURVE_COUNT };
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
    void initIncomeCourves();
    uint32_t _invoiceNumber = 0;
    const QStringList _tableHeader;
    QStringList _typeModel;
    const QStringList _currencyModel;
    QString _fileName;
    QList<QStringList> _readData;
    const QString _csvSeparator;
    QtCharts::QAbstractSeries *_chartSeries[COURVE_COUNT];
    int _xAxisMin = 0;
    int _xAxisMax = 1;
    Q_PROPERTY(QStringList tableHeader MEMBER _tableHeader CONSTANT)
    Q_PROPERTY(QStringList currencyModel MEMBER _currencyModel CONSTANT)
    Q_PROPERTY(QStringList typeModel MEMBER _typeModel CONSTANT)
    Q_PROPERTY(int xAxisMin MEMBER _xAxisMin CONSTANT)
    Q_PROPERTY(int xAxisMax MEMBER _xAxisMax CONSTANT)
};
