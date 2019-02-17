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
        Observations
    };
    void init();
    QString computeActualAmount(qreal amount, int currencyIndex, qreal rate);
    const QStringList _tableHeader;
    QStringList _typeModel;
    const QStringList _currencyModel;
    const QString _fileName;
    QList<QStringList> _readData;
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
};
