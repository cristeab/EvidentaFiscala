#include "tablemodel.h"
#include "qtcsv/variantdata.h"
#include "qtcsv/stringdata.h"
#include "qtcsv/reader.h"
#include "qtcsv/writer.h"
#include <QStandardPaths>
#include <QFile>
#include <QTimer>
#include <QDebug>

TableModel::TableModel() : _tableHeader({"Data", "Venituri prin Banca", "Venituri Lichide",
                                        "Cheltuieli prin Banca", "Cheltuieli Lichide",
                                        "Observatii"}),
                           _currencyModel({"RON", "$", "EUR"}),
                           _fileName(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) + "/PFA/ledger_pfa_2019.csv")
{
    setObjectName("tableModel");
    _typeModel = _tableHeader.mid(1, 4);
    QTimer::singleShot(0, this, &TableModel::init);
}

void TableModel::init()
{
    if (!QFile::exists(_fileName)) {
        QtCSV::StringData strData;
        strData.addRow(_tableHeader);
        QtCSV::Writer::write(_fileName, strData);
    }
    _readData = QtCSV::Reader::readToList(_fileName);
    if (!_readData.isEmpty() && (_readData.at(0).size() != _tableHeader.size())) {
        qCritical() << "Number of columns don't match expected format";
        _readData.clear();
    }
}

QVariant TableModel::data(const QModelIndex &index, int /*role*/) const
{
    const int row = index.row();
    if ((0 > row) || (row >= _readData.size())) {
        return "";
    }
    const QStringList rowData = _readData.at(row);
    const int col = index.column();
    if ((0 > col) || (col >= rowData.size())) {
        return "";
    }
    return rowData.at(row);
}

bool TableModel::add(const QString &date, int typeIndex, const QString &amount,
                     int currencyIndex, const QString &rate, const QString &obs)
{
    QStringList row;
    row << date;
    for (int i = 0; i < _typeModel.size(); ++i) {
        if (typeIndex == i) {
            //compute actual amount
            if (0 != currencyIndex) {
                bool ok = false;
                const double actualAmount = amount.toDouble(&ok) * rate.toDouble(&ok);
                if (ok) {
                    row << _typeModel.at(0) + "\t" + QString::number(actualAmount, 'f', 2);
                } else {
                    qCritical() << "Cannot convert to" << _typeModel.at(0);
                    row << "";
                }
            } else {
                row << _typeModel.at(0) + "\t" + amount;
            }
        } else {
            row << "";
        }
    }
    QString obsSuffix;
    if (0 != currencyIndex) {
        obsSuffix = QString(" (%1 = %2").arg(_typeModel.at(currencyIndex)).arg(_typeModel.at(0));
    }
    row << obs + obsSuffix;
    qDebug() << "Inserting" << row;
    QtCSV::StringData strData;
    strData.addRow(row);
    return QtCSV::Writer::write(_fileName, strData, QString(","), QString("\""),
                                QtCSV::Writer::APPEND);
}
