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
#include <QCoreApplication>
#include <QtCharts/QXYSeries>

TableModel::TableModel() : _tableHeader({"Data", "Venituri prin Banca", "Venituri Lichide",
                                        "Cheltuieli prin Banca", "Cheltuieli Lichide",
                                        "Numar Factura", "Observatii"}),
                           _currencyModel({"RON", "$", "EUR"}),
                           _csvSeparator(QString(";"))
{
    setObjectName("tableModel");

    _typeModel = _tableHeader.mid(1, 4);
#ifdef RELEASE_FOLDER
    _fileName = QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) +
            QString("/PFA/ledger_pfa_%1.csv").arg(QDate::currentDate().year());
#else
    _fileName = qApp->applicationDirPath() + QString("/ledger_pfa_%1.csv").arg(QDate::currentDate().year());
#endif
    QTimer::singleShot(0, this, &TableModel::init);
}

void TableModel::init()
{
    if (!QFile::exists(_fileName)) {
        QtCSV::StringData strData;
        strData.addRow(_tableHeader);
        if (!QtCSV::Writer::write(_fileName, strData, _csvSeparator)) {
            qCritical() << "Cannot create file";
            emit error("Fisierul CSV nu poate fi creat", true);
            return;
        }
    }
    emit layoutAboutToBeChanged();
    _readData = QtCSV::Reader::readToList(_fileName, _csvSeparator);
    if (!_readData.isEmpty()) {
        const auto& actTableHeader = _readData.at(0);
        if (actTableHeader.size() != _tableHeader.size()) {
            emit error("Fisierul CSV are un numar de coloane diferit de cel asteptat", true);
            return;
        }
        //check column names
        for (int i = 0; i < _tableHeader.size(); ++i) {
            if (_tableHeader.at(i) != actTableHeader.at(i)) {
                emit error("Fisierul CSV nu are coloanele asteptate", true);
                return;
            }
        }
    }
    emit layoutChanged();
    initInvoiceNumber();
}

QString TableModel::computeActualAmount(qreal amount, int currencyIndex, qreal rate)
{
    qreal actualAmount = amount;
    if (0 != currencyIndex) {
        actualAmount *= rate;
    }
    return toString(actualAmount) + " " + _currencyModel.at(0);
}

QString TableModel::toString(qreal num)
{
    return QLocale().toString(num, 'f', 4);
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
    case TableModel::InvoiceNumber:
        col = 5;
        break;
    case TableModel::Observations:
        col = 6;
        break;
    default:
        qCritical() << "Unknown role";
        return QVariant();
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
             { TableModel::InvoiceNumber, "invoiceNumber" },
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
    //generate invoice number
    if (0 != currencyIndex) {
        //2 invoice numbers (ro and en)
        row << QString("%1, %2").arg(_invoiceNumber + 1).arg(_invoiceNumber + 2);
        _invoiceNumber += 2;
    } else {
        //1 invoice number
        row << QString("%1").arg(_invoiceNumber + 1);
        _invoiceNumber += 1;
    }
    //observations
    QString obsSuffix;
    if (0 != currencyIndex) {
        obsSuffix = QString(" (%1 %2 @ 1 %2 = %3 %4)").arg(amount).arg(_currencyModel.at(currencyIndex)).arg(toString(rate)).arg(_currencyModel.at(0));
    }
    row << obs + obsSuffix;
    QtCSV::StringData strData;
    strData.addRow(row);
    const bool rc = QtCSV::Writer::write(_fileName, strData, _csvSeparator, QString("\""),
                                QtCSV::Writer::APPEND);
    if (rc) {
        emit layoutAboutToBeChanged();
        _readData.append(row);
        emit layoutChanged();
    }
    return rc;
}

void TableModel::initInvoiceNumber()
{
    for (const auto &row: _readData) {
        const int rowLen = row.size();
        if (2 < rowLen) {
            const QString invNo = row.at(rowLen-2);
            const auto tok = invNo.split(",");
            bool ok = false;
            for (int n = 0; n < tok.size(); ++n) {
                const uint32_t curInvNo = tok.at(n).toUInt(&ok);
                if (ok && curInvNo > _invoiceNumber) {
                    _invoiceNumber = curInvNo;
                }
            }
        }
    }
}

void TableModel::setChartSeries(int index, QtCharts::QAbstractSeries *series)
{
    if (0 <= index && COURVE_COUNT > index) {
        _chartSeries[index] = series;
    }
}

void TableModel::initIncomeCourves()
{
    struct MonthlyData {
        MonthlyData(double i, double e) : income(i), expense(e) {}
        MonthlyData() = default;
        double income = 0;
        double expense = 0;
    };

    QMap<int, MonthlyData> monthlyData;
    for (const auto &row: _readData) {
        const int rowLen = row.size();
        if (4 < rowLen) {
            const QDate date = QDate::fromString(row.at(0), "dd/MM/yyyy");
            if (!date.isValid()) {
                continue;
            }
            const int key = date.year() + date.month();
            double income = 0;
            double expense = 0;
            for (int i = 0; i < 4; ++i) {
                const QString val = row.at(i + 1);
                const auto tok = val.split(" ");
                bool ok = false;
                const double amount = tok.at(0).toDouble(&ok);
                if (ok) {
                    if (2 > i) {
                        income += amount;
                    } else {
                        expense += amount;
                    }
                }
            }
            monthlyData[key] = MonthlyData(income, expense);
        }
    }

    if (!monthlyData.isEmpty()) {
        qInfo() << "Found" << monthlyData.size() << "points";
        QtCharts::QXYSeries *grossIncomeSeries = static_cast<QtCharts::QXYSeries *>(_chartSeries[GROSS_INCOME_COURVE]);
        QtCharts::QXYSeries *expenseSeries = static_cast<QtCharts::QXYSeries *>(_chartSeries[EXPENSE_COURVE]);
        QtCharts::QXYSeries *netIncomeSeries = static_cast<QtCharts::QXYSeries *>(_chartSeries[NET_INCOME_COURVE]);

        QMapIterator<int,MonthlyData> i(monthlyData);
        int currentIndex = 0;
        while (i.hasNext()) {
            i.next();
            const MonthlyData &monthlyData = i.value();
            grossIncomeSeries->append(currentIndex, monthlyData.income);
            expenseSeries->append(currentIndex, monthlyData.expense);
            netIncomeSeries->append(currentIndex, monthlyData.income - monthlyData.expense);
            ++currentIndex;
        }
    }
}
