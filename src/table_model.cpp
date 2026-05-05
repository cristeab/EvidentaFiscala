#include "table_model.h"
#include "similarity_score.h"
#include "qtcsv/stringdata.h"
#include "qtcsv/reader.h"
#include "qtcsv/writer.h"
#include <QStandardPaths>
#include <QFile>
#include <QTimer>
#include <QDebug>
#include <QCoreApplication>
#include <QRegularExpression>
#include <QTextDocument>
#include <QTextDocumentWriter>
#include <QDesktopServices>
#include <QFileInfo>
#include <QXYSeries>
#include <QDir>

const QLocale TableModel::_locale;

static constexpr int RO_CURRENCY_INDEX = 0;

static constexpr int TRANSACTION_START_INDEX = TableModel::ColumnIndex::BANK_INCOME_INDEX;
static constexpr int TRANSACTION_ARRAY_LENGTH = 4;

static constexpr std::array<int, 2> INCOME_INDICES{TableModel::ColumnIndex::BANK_INCOME_INDEX,
                                      TableModel::ColumnIndex::CASH_INCOME_INDEX};

static const QStringList RO_TABLE_HEADER{"Data", "Venituri prin Banca", "Venituri Lichide",
                                        "Cheltuieli prin Banca", "Cheltuieli Lichide",
                                        "Numar Factura", "Observatii"};

TableModel::TableModel() : _tableHeader({tr("Date"), tr("Bank Income"), tr("Cash Income"),
tr("Bank Expenses"), tr("Cash Expenses"),
		 tr("Invoice Number"), tr("Comments")}),
	  _currencyModel({"RON", "USD", "EUR"}),
      _typeModel(_tableHeader.mid(TRANSACTION_START_INDEX, TRANSACTION_ARRAY_LENGTH)),
	  _csvSeparator(";"),
	  _dateFormats({"dd/MM/yyyy", "dd.MM.yyyy"})
{
	setObjectName("tableModel");

    _chartSeries.fill(nullptr);

	connect(_settings, &Settings::minIncomeChanged, this, &TableModel::resetMinIncome);
    connect(_settings, &Settings::useBarsChanged, this, &TableModel::initGraph);

	QTimer::singleShot(0, this, &TableModel::init);
}

void TableModel::init()
{
	updateTypeModel();

	const auto& ledgerFilePath = _settings->ledgerFilePath();
	if (ledgerFilePath.isEmpty()) {
	    emit error(tr("CSV file name is empty"), true);
	    return;
	}
	if (!QFile::exists(ledgerFilePath)) {
		QtCSV::StringData strData;
        strData.addRow(RO_TABLE_HEADER);
		if (!QtCSV::Writer::write(ledgerFilePath, strData, _csvSeparator)) {
			qCritical() << "Cannot create file";
			emit error(tr("CSV file cannot be created"), true);
			return;
		}
	}
	_readData = QtCSV::Reader::readToList(ledgerFilePath, _csvSeparator);
	if (!_readData.isEmpty()) {
		//check column names
        if (!std::ranges::equal(RO_TABLE_HEADER, _readData.at(0))) {
            emit error(tr("CSV file does not have the expected columns"), true);
            _readData.clear();
            return;
        }

        // check that all rows have the same number of columns
        auto const invalidColumnCount = std::ranges::any_of(_readData, [](auto const& row){
            return row.size() != COLUMN_COUNT;
        });
        if (invalidColumnCount) {
            emit error(tr("CSV file has a different number of columns than expected, %1")
                           .arg(COLUMN_COUNT), true);
            _readData.clear();
            return;
        }
	}

    initGraph();
	initInvoiceNumber();
}

QString TableModel::computeActualAmount(qreal amount, int currencyIndex, qreal rate) const
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
        return {};
	}
    const QStringList& rowData = (0 == row) ? _tableHeader : _readData.at(row);
	int col = -1;
	switch (role) {
	case TableModel::Date:
        col = DATE_INDEX;
		break;
	case TableModel::BankIncome:
        col = BANK_INCOME_INDEX;
		break;
	case TableModel::CashIncome:
        col = CASH_INCOME_INDEX;
		break;
	case TableModel::BankExpenses:
        col = BANK_EXPENSES_INDEX;
		break;
	case TableModel::CashExpenses:
        col = CASH_EXPENSES_INDEX;
		break;
	case TableModel::InvoiceNumber:
        col = INVOICE_NUMBER_INDEX;
		break;
    case TableModel::Comments:
        col = COMMENTS_INDEX;
		break;
	default:
		qCritical() << "Unknown role";
        return {};
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
         { TableModel::Comments, "comments" } };
}

bool TableModel::add(const QString &date, int typeIndex, qreal amount,
		     int currencyIndex, qreal rate, const QString &obs)
{
    QStringList row(COLUMN_COUNT);
    row[DATE_INDEX] = date;
    for (int i = TRANSACTION_START_INDEX; i <= TRANSACTION_ARRAY_LENGTH; ++i) {
        if (_typeModel.at(typeIndex) == _tableHeader.at(i)) {
            row[i] = computeActualAmount(amount, currencyIndex, rate);
            break;
		}
	}
	//generate invoice number only for income
    if (isIncome(typeIndex)) {
        if (RO_CURRENCY_INDEX != currencyIndex) {
			//2 invoice numbers (ro and en)
            row[INVOICE_NUMBER_INDEX] = QString("%1, %2").arg(_invoiceNumber + 1).arg(_invoiceNumber + 2);
			_invoiceNumber += 2;
		} else {
			//1 invoice number
            row[INVOICE_NUMBER_INDEX] = QString("%1").arg(_invoiceNumber + 1);
			_invoiceNumber += 1;
		}
	}
    //comments
	QString obsSuffix;
    if (RO_CURRENCY_INDEX != currencyIndex) {
		obsSuffix = QString(" (%1 %2 @ 1 %2 = %3 %4)").arg(amount).arg(_currencyModel.at(currencyIndex),
									       toString(rate), _currencyModel.at(0));
	}
    row[COMMENTS_INDEX] = obs + obsSuffix;

    if (auto const res = isValidRow(row); !res.has_value()) {
        qWarning() << res.error();
        setErrorMessage(res.error());
        return false;
    }

	QtCSV::StringData strData;
	strData.addRow(row);

	const auto& ledgerFilePath = _settings->ledgerFilePath();
	bool rc = ensureLastCharIsNewLine(ledgerFilePath);
	if (!rc) {
		return false;
	}
	rc = QtCSV::Writer::write(ledgerFilePath, strData, _csvSeparator, QString("\""),
				  QtCSV::Writer::WriteMode::APPEND);
	if (rc) {
		_readData.append(row);
        updateGraph(static_cast<int>(_readData.size()) - 1);
    } else {
        setErrorMessage(tr("Cannot write CSV file {}").arg(ledgerFilePath));
    }
	return rc;
}

void TableModel::initInvoiceNumber()
{
    // assumes that the rows are already sorted after the date, the most recent first
    // the invoice number must be the first found
    // or 0 if the last number is not one and the items read backwards are only increasing
    _invoiceNumber = 0;
    std::vector<int> nums;
    std::ranges::for_each(_readData, [&nums](auto const& row) {
        if (auto rowLen = row.size(); 2 < rowLen) {
            QString const& invNo = row.at(rowLen-2);

            std::vector<int> subArr;
            std::ranges::for_each(invNo.split(","), [&subArr](auto const& tok) {
                bool ok = false;
                if (const uint32_t curInvNo = tok.toUInt(&ok); ok) {
                    subArr.push_back(curInvNo);
                }
            });
            std::ranges::sort(subArr, [](int l, int r) { return l > r; });
            nums.append_range(subArr);
        }
    });
    if (!nums.empty() &&
        ((1 == nums.back()) || ((nums.at(0) - nums.back()) != (nums.size() - 1)))) {
        _invoiceNumber = nums.at(0);
    }
    qInfo() << "Last invoice number" << _invoiceNumber;
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
    auto it = std::ranges::find_if(_dateFormats, [&row, &date, this](auto const& dataFormat) {
        date = QDate::fromString(row.at(0), dataFormat);
        return date.isValid();
    });
    if (_dateFormats.end() == it) {
        qWarning() << "Invalid date, skipping row" << row;
        return false;
    }
    if (_dateFormats.begin() != it) {
        //update date to match default format
        QStringList newRow(row);
        newRow.replace(0, date.toString(_dateFormats.at(0)));
        _readData.replace(rowIndex, newRow);
    }

    // generate key as the last day of the month
    int lastDay = date.daysInMonth();
    QDate lastDayOfMonth(date.year(), date.month(), lastDay);
    key = QDateTime(lastDayOfMonth, QTime(0, 0, 0));

	income = 0;
	expense = 0;
	for (int i = 0; i < 4; ++i) {
		const auto& val = row.at(i + 1);
		if (val.isEmpty()) {
			continue;
		}

		static QRegularExpression re("RON\\h*(.+)", QRegularExpression::CaseInsensitiveOption);
		const auto match = re.match(val);
		if (!match.hasMatch()) {
            qWarning() << "Cannot match" << val;
            continue;
        }
		bool ok = false;
		QString amountStr = match.captured(1);
		amountStr = amountStr.simplified().replace(" ", "");
		const auto amount = _locale.toDouble(amountStr, &ok);
		if (!ok) {
            qWarning() << "Cannot convert amount" << match.captured(1);
            continue;
        }
		if (2 > i) {
			income += amount;
		} else {
			expense += amount;
		}
		//update amount to match default format
		QStringList newRow(row);
		newRow.replace(i + 1, "RON " + toString(amount));
		_readData.replace(rowIndex, newRow);
	}
	return true;
}

void TableModel::sortRows()
{
    if (1 >= _readData.size()) return;

    auto compareRows = [this](const QStringList &left, const QStringList &right) {
		const QDate dateLeft = QDate::fromString(left.at(0), _dateFormats.at(0));
		const QDate dateRight = QDate::fromString(right.at(0), _dateFormats.at(0));
		return dateLeft > dateRight;
	};

    emit layoutAboutToBeChanged();
    //skip table header
    std::sort(_readData.begin() + 1, _readData.end(), compareRows);
    emit layoutChanged();
}

void TableModel::initMonthlyData()
{
    QDateTime key;
    qreal income{};
    qreal expense{};
    _monthlyData.clear();
    for (int i = 1; i < _readData.size(); ++i) { //skip header
        if (parseRow(i, key, income, expense)) {
            _monthlyData[key].income += income;
            _monthlyData[key].expense += expense;
            updateXAxis(key);
        }
    }
}

void TableModel::updateMonthlyData(int rowIndex)
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
}

void TableModel::initGraph()
{
    initMonthlyData();
	sortRows();
    _settings->useBars() ? resetGraphBars() : resetGraphLines();
}

void TableModel::updateGraph(int rowIndex)
{
    updateMonthlyData(rowIndex);
	sortRows();
    _settings->useBars() ? resetGraphBars() : resetGraphLines();
}

void TableModel::resetGraphBars()
{
    _barMonths.clear();
    _barRevenue.clear();
    _barNetIncome.clear();

    for (auto const& [date, monthlyData]: _monthlyData.asKeyValueRange()) {
        _barMonths << QLocale().toString(date, "MMM yyyy");
        _barRevenue << monthlyData.income;
        updateYAxis(monthlyData.income);
        const auto netIncome = monthlyData.income - monthlyData.expense;
        _barNetIncome << netIncome;
        updateYAxis(netIncome);
    }

    emit barMonthsChanged();
    emit barRevenueChanged();
    emit barNetIncomeChanged();
}

void TableModel::resetGraphLines()
{
    std::ranges::for_each(_chartSeries, [](auto* elem) {
        if (elem) elem->clear();
    });

    if (_monthlyData.isEmpty()) {
        return;
    }

    auto appendToCurve = [&](int curveIndex, qint64 timeVal, qreal amount) {
        if (nullptr != _chartSeries[curveIndex]) {
            _chartSeries[curveIndex]->append(static_cast<qreal>(timeVal),
                                             amount);
            updateYAxis(amount);
        }
    };

    for (auto const& [date, monthlyData]: _monthlyData.asKeyValueRange()) {
        const qint64 timeVal = date.toMSecsSinceEpoch();
        appendToCurve(GROSS_INCOME_CURVE, timeVal, monthlyData.income);
        appendToCurve(EXPENSE_CURVE, timeVal, monthlyData.expense);
        appendToCurve(NET_INCOME_CURVE, timeVal,
                      monthlyData.income - monthlyData.expense);
    }

    setXAxisTickCount(static_cast<int>(_monthlyData.size()));
    resetMinIncome();
}

void TableModel::updateXAxis(const QDateTime &val)
{
    if (!_xAxisMin.isValid() || _xAxisMin > val) {
        setXAxisMin(val);
    }
    if (!_xAxisMax.isValid() || _xAxisMax < val) {
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

bool TableModel::ensureLastCharIsNewLine(const QString& filePath)
{
    QFile file(filePath);
    if (!file.open(QIODevice::ReadWrite | QIODevice::Text)) {
        qWarning() << "Cannot open" << file.errorString();
        return false;
    }

	const qint64 fileSize = file.size();
	file.seek(fileSize-1);
	char ch{};
    if (!file.getChar(&ch)) {
        qWarning() << "Cannot getChar" << file.errorString();
        return false;
    }

    bool rc{};
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

	return rc;
}

void TableModel::generateRegistry()
{
	if (_monthlyData.isEmpty()) {
		return;
	}

    auto const total = std::ranges::fold_left(_monthlyData, MonthlyData{},
                    [](auto const& left, auto const& right) {
        return MonthlyData{.income = left.income + right.income,
                           .expense = left.expense + right.expense};
    });

    qInfo() << "Gross income" << total.income;
    qInfo() << "Expenses" << total.expense;
    qInfo() << "Net income" << total.income - total.expense;

	//generate HTML document
	const QString year = _monthlyData.keyBegin()->toString("yyyy");
    QString content = "<br><p>Anul " + year + "</p>";
    content += "<p>Rectificare</p>";
    content += "<p>Activit&#259;&#355;i de consultan&#355;&#259; &#238;n tehnologia informa&#355;iei</p>";
	content += "<br>";
	content += "<table>";
    content += "<tr><th>Nr. crt.</th><th>"
               "Elemente de calcul pentru stabilirea venitului net anual/pierderii nete anuale</th><th>"
               "Valoare<br>- lei -</th></tr>";
    content += "<tr><td align=\"center\">1</td><td>&nbsp;Venit brut</td><td align=\"center\">" +
               toString(total.income) + "</td></tr>";
    content += "<tr><td align=\"center\">2</td><td>&nbsp;Cheltuieli</td><td align=\"center\">" +
               toString(total.expense) + "</td></tr>";
	content += "</table>";
	QTextDocument doc;
    doc.setMetaInformation(QTextDocument::DocumentTitle, "Registru de Evidenta Fiscala");
	doc.setHtml(content);

	QDir dir(_settings->workingFolderPath());
	const auto fileName = "RegistruEvidentaFiscala_" + year + ".odt";
	QTextDocumentWriter docWriter(dir.filePath(fileName), "odf");
	const bool rc = docWriter.write(&doc);
	if (rc) {
		QDesktopServices::openUrl("file://" + docWriter.fileName());
	} else {
		const QString msg = tr("Cannot write to ") + docWriter.fileName();
		qCritical() << msg;
		emit error(msg, false);
	}
}

void TableModel::openLedger(const QUrl &url)
{
	_settings->setLedgerFilePath(url.toLocalFile());
	QTimer::singleShot(0, this, &TableModel::init);
}

void TableModel::resetMinIncome()
{
	if ((nullptr != _chartSeries[THRESHOLD_CURVE]) &&
	    (nullptr != _chartSeries[GROSS_INCOME_CURVE])) {
		const auto* series = _chartSeries[GROSS_INCOME_CURVE];
		const auto minIncome = _settings->minIncome();
		_chartSeries[THRESHOLD_CURVE]->clear();
		_chartSeries[THRESHOLD_CURVE]->append(series->at(0).x(), minIncome);
		_chartSeries[THRESHOLD_CURVE]->append(series->at(series->count() - 1).x(), minIncome);
	} else {
		qWarning() << "Cannot reset minimum income";
	}
}

void TableModel::updateTypeModel()
{
	static constexpr int defaultTableHeaderIndex{3};

	// update combobox
	_typeModel.clear();
    for (int i = 1; i < (COLUMN_COUNT - 2); ++i) {
		if (isColumnVisible(i)) {
			_typeModel.append(_tableHeader.at(i));
		}
	}
	emit typeModelChanged();

	// update default index in combobox
	setDefaultTypeModelIndex(static_cast<int>(_typeModel.indexOf(_tableHeader.at(defaultTableHeaderIndex))));
}

void TableModel::setInvisibleColumns(const QList<int> &indexList)
{
	qDebug() << "Invisible cols" << indexList;

	// update table
	std::unordered_set<int> newInvisibleColumns;
	for (auto index: indexList) {
		newInvisibleColumns.emplace(index);
	}
	if (_settings->_invisibleColumns != newInvisibleColumns) {
		_settings->_invisibleColumns = newInvisibleColumns;
		emit error(tr("Restart the application to apply changes"), false);
	}

	updateTypeModel();
}

bool TableModel::isIncome(int typeIndex) const
{
    const auto& transactionName = _typeModel.at(typeIndex);
    return std::ranges::any_of(INCOME_INDICES,
                       [&](int idx) { return transactionName == _tableHeader.at(idx); });
}

std::expected<void,QString> TableModel::isValidRow(QStringList const& row)
{
	if (_readData.empty()) {
        return {};
	}
    if (row.size() != COLUMN_COUNT) {
        return std::unexpected(tr("Invalid number of columns in candidate row"));
    }

    auto parseDate = [&](QString const &dateString) -> QDate {
        for (auto const &format : _dateFormats) {
            const QDate date = QDate::fromString(dateString, format);
            if (date.isValid()) {
                return date;
            }
        }
        return QDate();
    };

    auto parseAmount = [&](QString const &value) -> qreal {
        if (value.isEmpty()) {
            return 0;
        }
        static QRegularExpression re("RON\\h*(.+)", QRegularExpression::CaseInsensitiveOption);
        const auto match = re.match(value);
        if (!match.hasMatch()) {
            return 0;
        }

        QString amountStr = match.captured(1);
        amountStr = amountStr.simplified().replace(" ", "");
        bool ok = false;
        const qreal amount = _locale.toDouble(amountStr, &ok);
        return ok ? amount : 0;
    };

    const QDate rowDate = parseDate(row.at(DATE_INDEX));
    if (!rowDate.isValid()) {
        return std::unexpected(tr("Invalid date in candidate row"));
    }

    // transaction type and sum for the candidate row
    int rowTypeIndex = -1;
    qreal rowSum = 0;

    for (int i = BANK_INCOME_INDEX; i <= CASH_EXPENSES_INDEX; ++i) {
        const qreal amount = parseAmount(row.at(i));
        if (amount != 0) {
            if (rowTypeIndex == -1) {
                rowTypeIndex = i;
                rowSum = amount;
            } else {
                return std::unexpected(tr("Multiple transactions in candidate row"));
            }
        }
    }

    if (rowTypeIndex < 0) {
        return std::unexpected(tr("No transaction amount in candidate row"));
    }

    auto const& rowComments = row.at(COMMENTS_INDEX);
    for (int idx = 1; idx < _readData.size(); ++idx) {
        const QStringList &existingRow = _readData.at(idx);
        if (existingRow.size() != COLUMN_COUNT) {
            continue;
        }

        if (const QDate existingDate = parseDate(existingRow.at(DATE_INDEX));
            !existingDate.isValid() || existingDate != rowDate) {
            continue;
        }

        // existing transaction type and sum
        int existingTypeIndex = -1;
        qreal existingSum = 0;

        for (int i = BANK_INCOME_INDEX; i <= CASH_EXPENSES_INDEX; ++i) {
            const qreal amount = parseAmount(existingRow.at(i));
            if (amount != 0 && existingTypeIndex == -1) {
                existingTypeIndex = i;
                existingSum = amount;
                break;
            }
        }

        if (existingTypeIndex != rowTypeIndex) {
            continue;
        }

        if (qAbs(existingSum - rowSum) < 1.0 &&
            0.7 < calculateSimilarity(rowComments, existingRow.at(COMMENTS_INDEX))) {
            return std::unexpected(tr("Found possible duplicate row #%1").arg(idx));
        }
    }

    return {};
}

QStringList TableModel::suggestions(QString input)
{
    input = input.trimmed();
    if (3 > input.size()) return {};

    QStringList res;
    QSet<QString> seen;
    int max{};
    for (auto const& row: _readData) {
        auto const& text = row.at(TableModel::ColumnIndex::COMMENTS_INDEX);
        if (!seen.contains(text) &&
            text.contains(input, Qt::CaseInsensitive)) {
            res.push_back(text);
            seen.insert(text);
            max = qMax(max, text.size());
        }
    }
    setSuggestionMaxLength(max);
    return res;
}
