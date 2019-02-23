#pragma once

#include <QAbstractTableModel>
#include <QStringList>

class TableModel : public QAbstractTableModel
{
    Q_OBJECT
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
    uint32_t _invoiceNumber = 0;
    const QStringList _tableHeader;
    QStringList _typeModel;
    const QStringList _currencyModel;
    QString _fileName;
    QList<QStringList> _readData;
    const QString _csvSeparator;
    Q_PROPERTY(QStringList tableHeader MEMBER _tableHeader CONSTANT)
    Q_PROPERTY(QStringList currencyModel MEMBER _currencyModel CONSTANT)
    Q_PROPERTY(QStringList typeModel MEMBER _typeModel CONSTANT)
public:
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
signals:
    void error(const QString &msg, bool fatal = false);
};
