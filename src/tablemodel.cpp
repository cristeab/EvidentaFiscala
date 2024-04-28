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
#include <QRegularExpression>
#include <QTextDocument>
#include <QTextDocumentWriter>
#include <QDesktopServices>
#include <QFileInfo>
#include <QXYSeries>

const QLocale TableModel::_locale;

TableModel::TableModel() : _tableHeader({"Data", "Venituri prin Banca", "Venituri Lichide",
			 "Cheltuieli prin Banca", "Cheltuieli Lichide",
			 "Numar Factura", "Observatii"}),
	  _currencyModel({"RON", "USD", "EUR"}),
	  _typeModel(_tableHeader.mid(1, 4)),
	  _csvSeparator(";"),
	  _dateFormats({"dd/MM/yyyy", "dd.MM.yyyy"})
{
	setObjectName("tableModel");

	setFileName(QStandardPaths::writableLocation(QStandardPaths::DocumentsLocation) +
		    QString("/PFA/ledger_pfa_%1.csv").arg(QDate::currentDate().year()));
	for (int i = 0; i < CURVE_COUNT; ++i) {
		_chartSeries[i] = nullptr;
	}
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
	initInvoiceNumber();
	initIncomeCourves();
}

QString TableModel::computeActualAmount(qreal amount, int currencyIndex, qreal rate)
{
	qreal actualAmount = amount;
	if (0 != currencyIndex) {
		actualAmount *= rate;
	}
	return _currencyModel.at(0) + " " + toString(actualAmount);
}

QString TableModel::toString(qreal num)
{
	return _locale.toString(num, 'f', 4);
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
	//generate invoice number only for income
	if ((0 == typeIndex) || (1 == typeIndex)) {
		if (0 != currencyIndex) {
			//2 invoice numbers (ro and en)
			row << QString("%1, %2").arg(_invoiceNumber + 1).arg(_invoiceNumber + 2);
			_invoiceNumber += 2;
		} else {
			//1 invoice number
			row << QString("%1").arg(_invoiceNumber + 1);
			_invoiceNumber += 1;
		}
	} else {
		row << "";
	}
	//observations
	QString obsSuffix;
	if (0 != currencyIndex) {
		obsSuffix = QString(" (%1 %2 @ 1 %2 = %3 %4)").arg(amount).arg(_currencyModel.at(currencyIndex),
									       toString(rate), _currencyModel.at(0));
	}
	row << obs + obsSuffix;
	QtCSV::StringData strData;
	strData.addRow(row);
	bool rc = ensureLastCharIsNewLine();
	if (!rc) {
		return false;
	}
	rc = QtCSV::Writer::write(_fileName, strData, _csvSeparator, QString("\""),
				  QtCSV::Writer::WriteMode::APPEND);
	if (rc) {
		_readData.append(row);
		updateIncomeCourves(_readData.size() - 1);
	}
	return rc;
}

void TableModel::initInvoiceNumber()
{
	for (const auto &row: std::as_const(_readData)) {
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

void TableModel::setChartSeries(int index, QAbstractSeries *series)
{
	if (0 <= index && CURVE_COUNT > index) {
		_chartSeries[index] = static_cast<QXYSeries *>(series);
	}
}

bool TableModel::parseRow(int rowIndex, QDateTime &key, qreal &income,
			  qreal &expense)
{
	const auto &row = _readData.at(rowIndex);
	QDate date;
	for (int i = 0; i < _dateFormats.size(); ++i) {
		date = QDate::fromString(row.at(0), _dateFormats.at(i));
		if (date.isValid()) {
			if (0 < i) {
				//update date to match default format
				QStringList newRow(row);
				newRow.replace(0, date.toString(_dateFormats.at(0)));
				_readData.replace(rowIndex, newRow);
			}
			break;
		}
	}
	if (!date.isValid()) {
		qWarning() << "Invalid date, skipping row" << row;
		return false;
	}

	key = QDateTime::currentDateTime();
	key.setDate(QDate(date.year(), date.month(), 15));//middle of the month
	key.setTime({});
	income = 0;
	expense = 0;
	for (int i = 0; i < 4; ++i) {
		const QString val = row.at(i + 1);
		if (val.isEmpty()) {
			continue;
		}

		static QRegularExpression re("RON\\h*(.+)", QRegularExpression::CaseInsensitiveOption);
		auto match = re.match(val);
		if (match.hasMatch()) {
			bool ok = false;
			QString amountStr = match.captured(1);
			amountStr = amountStr.simplified().replace(" ", "");
			const qreal amount = _locale.toDouble(amountStr, &ok);
			if (ok) {
				if (2 > i) {
					income += amount;
				} else {
					expense += amount;
				}
				//update amount to match default format
				QStringList newRow(row);
				newRow.replace(i + 1, "RON " + toString(amount));
				_readData.replace(rowIndex, newRow);
			} else {
				qWarning() << "Cannot convert amount" << match.captured(1);
			}
		} else {
			qWarning() << "Cannot match" << val;
		}
	}
	return true;
}

void TableModel::sortRows()
{
	auto compareRows = [&](const QStringList &left, const QStringList &right) {
		const QDate dateLeft = QDate::fromString(left.at(0), _dateFormats.at(0));
		const QDate dateRight = QDate::fromString(right.at(0), _dateFormats.at(0));
		return dateLeft > dateRight;
	};
	if (1 < _readData.size()) {
		emit layoutAboutToBeChanged();
		//skip table header
		std::sort(++_readData.begin(), _readData.end(), compareRows);
		emit layoutChanged();
	}
}

void TableModel::initIncomeCourves()
{
	QDateTime key;
	qreal income{};
	qreal expense{};
	//skip header
	_monthlyData.clear();
	for (int i = 1; i < _readData.size(); ++i) {
		if (parseRow(i, key, income, expense)) {
			_monthlyData[key].income += income;
			_monthlyData[key].expense += expense;
			updateXAxis(key);
		}
	}
	sortRows();
	resetCurves();
}

void TableModel::updateIncomeCourves(int rowIndex)
{
	QDateTime key;
	qreal income{};
	qreal expense{};
	if (!parseRow(rowIndex, key, income, expense)) {
		return;
	}
	_monthlyData[key].income += income;
	_monthlyData[key].expense += expense;
	updateXAxis(key);
	sortRows();
	resetCurves();
}

void TableModel::updateXAxis(const QDateTime &val)
{
	if (_xAxisMin.isValid()) {
		if (_xAxisMin > val) {
			setXAxisMin(val);
		}
	} else {
		setXAxisMin(val);
	}
	if (_xAxisMax.isValid()) {
		if (_xAxisMax < val) {
			setXAxisMax(val);
		}
	} else {
		setXAxisMax(val);
	}
}

void TableModel::updateYAxis(qreal amount)
{
	if (_yAxisMin > amount) {
		setYAxisMin(amount);
	}
	if (_yAxisMax < amount) {
		setYAxisMax(amount);
	}
}

void TableModel::resetCurves()
{
	for (auto* s: _chartSeries) {
		if (nullptr != s) {
			s->clear();
		}
	}
	if (!_monthlyData.isEmpty()) {
		auto appendToCurve = [&](int curveIndex, qint64 timeVal, qreal amount) {
			if (nullptr != _chartSeries[curveIndex]) {
				_chartSeries[curveIndex]->append(static_cast<qreal>(timeVal),
								 static_cast<qreal>(amount));
				updateYAxis(amount);
			}
		};
		QMapIterator<QDateTime,MonthlyData> i(_monthlyData);
		while (i.hasNext()) {
			i.next();
			const qint64 timeVal = i.key().toMSecsSinceEpoch();
			const MonthlyData &monthlyData = i.value();
			appendToCurve(GROSS_INCOME_CURVE, timeVal, monthlyData.income);
			appendToCurve(EXPENSE_CURVE, timeVal, monthlyData.expense);
			appendToCurve(NET_INCOME_CURVE, timeVal,
				      monthlyData.income - monthlyData.expense);
		}
		setXAxisTickCount(_monthlyData.size());
		if ((nullptr != _chartSeries[THRESHOLD_CURVE]) &&
		    (nullptr != _chartSeries[GROSS_INCOME_CURVE])) {
			auto* series = _chartSeries[GROSS_INCOME_CURVE];
			_chartSeries[THRESHOLD_CURVE]->append(series->at(0).x(), THRESHOLD_VALUE);
			_chartSeries[THRESHOLD_CURVE]->append(series->at(series->count() - 1).x(), THRESHOLD_VALUE);
		}
	}
}

bool TableModel::ensureLastCharIsNewLine()
{
	bool rc{};
	QFile file(_fileName);
	if (file.open(QIODevice::ReadWrite | QIODevice::Text)) {
		const qint64 fileSize = file.size();
		file.seek(fileSize-1);
		char ch{};
		if (file.getChar(&ch)) {
			if ('\n' != ch) {//only preOSX can have line ending a CR, ignore this case
				file.seek(fileSize);
				rc = file.putChar('\n');
				if (rc) {
					qInfo() << "Put LF at the end of the file";
				} else {
					qWarning() << "Cannot putChar" << file.errorString();
				}
			} else {
				qInfo() << "Found LF at the end of the file";
				rc = true;
			}
		} else {
			qWarning() << "Cannot getChar" << file.errorString();
		}
	} else {
		qWarning() << "Cannot open" << file.errorString();
	}
	return rc;
}

void TableModel::generateRegistry()
{
	if (_monthlyData.isEmpty()) {
		return;
	}
	qreal totalIncome = 0;
	qreal totalExpense = 0;
	for (const auto &item: std::as_const(_monthlyData)) {
		totalIncome += item.income;
		totalExpense += item.expense;
	}
	qInfo() << "Gross income" << totalIncome;
	qInfo() << "Expenses" << totalExpense;
	qInfo() << "Net income" << totalIncome - totalExpense;

	//generate HTML document
	const QString year = _monthlyData.keyBegin()->toString("yyyy");
	QString content = "<br><p>Anul " + year + "</p>";
	content += "<p>Rectificare</p>";
	content += "<p>Activit&#259;&#355;i de consultan&#355;&#259; &#238;n tehnologia informa&#355;iei</p>";
	content += "<br>";
	content += "<table>";
	content += "<tr><th>Nr. crt.</th><th>Elemente de calcul pentru stabilirea venitului net anual/pierderii nete anuale</th><th>Valoare<br>- lei -</th></tr>";
	content += "<tr><td align=\"center\">1</td><td>&nbsp;Venit brut</td><td align=\"center\">" + toString(totalIncome) + "</td></tr>";
	content += "<tr><td align=\"center\">2</td><td>&nbsp;Cheltuieli</td><td align=\"center\">" + toString(totalExpense) + "</td></tr>";
	content += "</table>";
	QTextDocument doc;
	doc.setMetaInformation(QTextDocument::DocumentTitle, "Registru de Evidenta Fiscala");
	doc.setHtml(content);
	const QString path = QFileInfo(_fileName).path();
	QTextDocumentWriter docWriter(path + "/RegistruEvidentaFiscala_"+year+".odt", "odf");
	const bool rc = docWriter.write(&doc);
	if (rc) {
		QDesktopServices::openUrl("file://" + docWriter.fileName());
	} else {
		const QString msg = "Cannot write to " + docWriter.fileName();
		qCritical() << msg;
		emit error(msg, false);
	}
}

void TableModel::openLedger(const QUrl &url)
{
	setFileName(url.toLocalFile());
	QTimer::singleShot(0, this, &TableModel::init);
}
