#include "ui_controller.h"
#include "rest_client.h"
#include "table_model.h"
#include <QXYSeries>
#include <QTextDocument>
#include <QTextDocumentWriter>
#include <QDir>
#include <QDesktopServices>
#include <QFileInfo>

UiController::UiController(QObject *parent)
    : QObject{parent},
    _settings(new Settings(this)),
    _restClient(new RestClient(this)),
    _tableModel(new TableModel(this))
{
    setObjectName("controller");

    _chartSeries.fill(nullptr);

    connect(_settings, &Settings::minIncomeChanged, this, &UiController::resetMinIncome);
    connect(_settings, &Settings::useBarsChanged, this, &UiController::initGraph);

    connect(_restClient, &RestClient::conversionRateReady, this, [this](double value, QString const& currency) {
        if (0 == _tableModel->currentCurrency().compare(currency, Qt::CaseInsensitive)) {
            setConversionRate(value);
        } else {
            qWarning() << "Ignoring conversion rate" << value << "for" << currency;
        }
    }, Qt::QueuedConnection);

    connect(_tableModel, &TableModel::error, this, &UiController::error);

    initBackup();
    connect(_settings, &Settings::enableBackupChanged, this, &UiController::initBackup);
}

void UiController::setChartSeries(int index, QAbstractSeries *series)
{
    if (0 <= index && CURVE_COUNT > index) {
        _chartSeries[index] = static_cast<QXYSeries *>(series);
    }
}

void UiController::generateRegistry()
{
    if (_tableModel->isEmpty()) {
        return;
    }

    auto const total = _tableModel->total();
    qInfo() << "Gross income" << total.income;
    qInfo() << "Expenses" << total.expense;
    qInfo() << "Net income" << total.income - total.expense;

    //generate HTML document
    const QString year = _tableModel->year();
    QString content = "<br><p>Anul " + year + "</p>";
    content += "<p>Rectificare</p>";
    content += "<p>Activit&#259;&#355;i de consultan&#355;&#259; &#238;n tehnologia informa&#355;iei</p>";
    content += "<br>";
    content += "<table>";
    content += "<tr><th>Nr. crt.</th><th>"
               "Elemente de calcul pentru stabilirea venitului net anual/pierderii nete anuale</th><th>"
               "Valoare<br>- lei -</th></tr>";
    content += "<tr><td align=\"center\">1</td><td>&nbsp;Venit brut</td><td align=\"center\">" +
               TableModel::toString(total.income) + "</td></tr>";
    content += "<tr><td align=\"center\">2</td><td>&nbsp;Cheltuieli</td><td align=\"center\">" +
               TableModel::toString(total.expense) + "</td></tr>";
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

void UiController::openLedger(const QUrl &url)
{
    _tableModel->openLedger(url.toLocalFile());
}

void UiController::initGraph()
{
    _tableModel->initMonthlyData();
    _tableModel->sortRows();
    _settings->useBars() ? resetGraphBars() : resetGraphLines();
}

void UiController::updateGraph(int rowIndex)
{
    _tableModel->updateMonthlyData(rowIndex);
    _tableModel->sortRows();
    _settings->useBars() ? resetGraphBars() : resetGraphLines();
}

void UiController::resetGraphBars()
{
    _barMonths.clear();
    _barRevenue.clear();
    _barNetIncome.clear();

    for (auto const& [date, monthlyData]: _tableModel->monthlyData()) {
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

void UiController::resetGraphLines()
{
    std::ranges::for_each(_chartSeries, [](auto* elem) {
        if (elem) elem->clear();
    });

    if (_tableModel->isEmpty()) {
        return;
    }

    auto appendToCurve = [&](int curveIndex, qint64 timeVal, qreal amount) {
        if (nullptr != _chartSeries[curveIndex]) {
            _chartSeries[curveIndex]->append(static_cast<qreal>(timeVal),
                                             amount);
            updateYAxis(amount);
        }
    };

    for (auto const& [date, monthlyData]: _tableModel->monthlyData()) {
        const qint64 timeVal = date.toMSecsSinceEpoch();
        appendToCurve(GROSS_INCOME_CURVE, timeVal, monthlyData.income);
        appendToCurve(EXPENSE_CURVE, timeVal, monthlyData.expense);
        appendToCurve(NET_INCOME_CURVE, timeVal,
                      monthlyData.income - monthlyData.expense);
    }

    setXAxisTickCount(static_cast<int>(_tableModel->size()));
    resetMinIncome();
}

void UiController::updateXAxis(const QDateTime &val)
{
    if (!_xAxisMin.isValid() || _xAxisMin > val) {
        setXAxisMin(val);
    }
    if (!_xAxisMax.isValid() || _xAxisMax < val) {
        setXAxisMax(val);
    }
}

void UiController::updateYAxis(qreal amount)
{
    if (_yAxisMin > amount) {
        setYAxisMin(amount);
    }
    if (_yAxisMax < amount) {
        setYAxisMax(amount);
    }
}

void UiController::resetMinIncome()
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

void UiController::updateCurrencyRate(QString const& date)
{
    auto const ci = _tableModel->currencyModelIndex();
    if (0 == ci || date.isEmpty() || !_restClient) {
        return;
    }
    _restClient->requestConversionRate(_tableModel->currencyModel().at(ci),
                                       QDate::fromString(date, _dateFormat));
}

void UiController::initBackup()
{
    _gitClient.reset();
    if (!_settings->enableBackup()) {
        return;
    }
    _gitClient = std::make_unique<GitClient>(_settings);

    auto res = _gitClient->initRepo().and_then([this](GitClient::RepoStatus /*repoStatus*/) {
        return _gitClient->openRepo();
    });
    if (!res) {
        qWarning() << res.error();
        emit error(res.error(), false);
    }
}

void UiController::tryBackup(QString const& filePath)
{
    if (!_gitClient) {
        qDebug() << "Git client is not enabled";
        return;
    }

    QFileInfo const fileInfo(filePath);
    QString const& fileName = fileInfo.fileName();

    auto const gitFiles = _gitClient->filesWithStatus(GitClient::FileStatus::Added |
                                                      GitClient::FileStatus::Modified |
                                                      GitClient::FileStatus::Renamed |
                                                      GitClient::FileStatus::Untracked);
    if (gitFiles.contains(fileName)) {
        qInfo() << "Detected changes" << "file" << filePath;
        backup(filePath);
    }
    qDebug() << "No changes detected to" << filePath << gitFiles;
}

void UiController::backup(QString const& filePath)
{
    if (!_gitClient) {
        qDebug() << "Git client is not enabled";
        return;
    }

    QFileInfo const fileInfo(filePath);
    QString const& fileName = fileInfo.fileName();
    QString const& timestamp = QDateTime::currentDateTime().toString(Qt::ISODate);
    QString const& commitMsg = QString(
                                  "%1: auto-save local changes, Timestamp: %2, Generated-By: %3 v%4"
                                  ).arg(fileName).arg(timestamp).arg(APP_NAME).arg(APP_VERSION);

    auto const res = _gitClient->stageAndCommit(fileName, commitMsg);
    if (!res) {
        qWarning() << res.error();
        emit error(res.error(), false);
        return;
    }
    qInfo() << "Successfully backed up" << fileName;
}

QUrl UiController::fromLocalFile(QString const& local)
{
    if (local.isEmpty()) {
        return QDir::homePath();
    }
    return QUrl::fromLocalFile(local);
}

QString UiController::toLocalFile(QUrl const& url)
{
    return url.toLocalFile();
}

QString UiController::createFileName()
{
    static constexpr int MAX_COUNT{100};

    auto const& path = _settings->workingFolderPath();
    auto const year = QDate::currentDate().year();

    auto fileName = Settings::LEDGER_FILENAME_PREFIX + QString("%1.csv").arg(year);
    auto filePath = QDir(path).filePath(fileName);
    if (!QFile::exists(filePath)) {
        return filePath;
    }

    int count{};
    while (count < MAX_COUNT) {
        fileName = Settings::LEDGER_FILENAME_PREFIX + QString("%1_%2.csv").arg(year).arg(count++);
        filePath = QDir(path).filePath(fileName);
        if (!QFile::exists(filePath)) {
            return filePath;
        }
    }
    qCritical() << "Cannot create a new file name" << filePath;
    emit error(tr("Cannot create a new file name %1").arg(filePath), true);
    return {};
}
