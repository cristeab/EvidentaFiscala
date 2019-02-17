#include "tablemodel.h"
#include "qtcsv/variantdata.h"
#include "qtcsv/stringdata.h"
#include "qtcsv/reader.h"
#include "qtcsv/writer.h"
#include <QStandardPaths>
#include <QFile>
#include <QTimer>
#include <QDebug>
#include <QDate>

TableModel::TableModel() : _tableHeader({"Data", "Venituri prin Banca", "Venituri Lichide",
                                        "Cheltuieli prin Banca", "Cheltuieli Lichide",
                                        "Observatii"}),
                           _currencyModel({"RON", "$", "EUR"}),
                           _csvSeparator(QString(";"))
{
    setObjectName("tableModel");
    _typeModel = _tableHeader.mid(1, 4);
    _fileName = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) +
            QString("/PFA/ledger_pfa_%1.csv").arg(QDate::currentDate().year());
    QTimer::singleShot(0, this, &TableModel::init);
}

void TableModel::init()
{
    if (!QFile::exists(_fileName)) {
        QtCSV::StringData strData;
        strData.addRow(_tableHeader);
        QtCSV::Writer::write(_fileName, strData, _csvSeparator);
    }
    emit layoutAboutToBeChanged();
    _readData = QtCSV::Reader::readToList(_fileName, _csvSeparator);
    if (!_readData.isEmpty() && (_readData.at(0).size() != _tableHeader.size())) {
        qCritical() << "Number of columns don't match expected format";
        _readData.clear();
    }
    emit layoutChanged();
}

QString TableModel::computeActualAmount(qreal amount, int currencyIndex, qreal rate)
{
    qreal actualAmount = amount;
    if (0 != currencyIndex) {
        actualAmount *= rate;
    }
    return QString::number(actualAmount, 'f', 2) + " " + _currencyModel.at(0);
}

QVariant TableModel::data(const QModelIndex &index, int role) const
{
    const int row = index.row();
    if ((0 > row) || (row >= _readData.size())) {
        return "";
    }
    const QStringList rowData = _readData.at(row);
    int col = -1;
    switch (role) {
    case TableModel::Date:
        col = 0;
        break;
    case TableModel::BankIncome:
        col = 1;
        break;
    case TableModel::CashIncome:
        col = 2;
        break;
    case TableModel::BankExpenses:
        col = 3;
        break;
    case TableModel::CashExpenses:
        col = 4;
        break;
    case TableModel::Observations:
        col = 5;
        break;
    default:
        break;
    }
    return rowData.at(col);
}

QHash<int, QByteArray> TableModel::roleNames() const
{
    return { { TableModel::Date, "date" },
             { TableModel::BankIncome, "bankIncome" },
             { TableModel::CashIncome, "cashIncome" },
             { TableModel::BankExpenses, "bankExpenses" },
             { TableModel::CashExpenses, "cashExpenses" },
             { TableModel::Observations, "observations" } };
}

bool TableModel::add(const QString &date, int typeIndex, qreal amount,
                     int currencyIndex, qreal rate, const QString &obs)
{
    QStringList row;
    row << date;
    for (int i = 0; i < _typeModel.size(); ++i) {
        if (typeIndex == i) {
            row << computeActualAmount(amount, currencyIndex, rate);
        } else {
            row << "";
        }
    }
    QString obsSuffix;
    if (0 != currencyIndex) {
        obsSuffix = QString(" (1%1 = %2 %3)").arg(_currencyModel.at(currencyIndex)).arg(QString::number(rate, 'f', 2)).arg(_currencyModel.at(0));
    }
    row << obs + obsSuffix;
    QtCSV::StringData strData;
    strData.addRow(row);
    const bool rc = QtCSV::Writer::write(_fileName, strData, _csvSeparator, QString("\""),
                                QtCSV::Writer::APPEND);
    if (rc) {
        emit layoutAboutToBeChanged();
        _readData.insert(1, row);//first row is the header
        emit layoutChanged();
    }
    return rc;
}
