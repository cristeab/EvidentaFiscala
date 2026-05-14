#pragma once

#include "git_client.h"
#include "settings.h"
#include <QDateTime>
#include <memory>

class QAbstractSeries;
class QXYSeries;
class RestClient;
class TableModel;

class UiController : public QObject
{
    Q_OBJECT

    QML_CONSTANT_PROPERTY(QString, dateFormat, "dd/MM/yyyy")

    QML_READABLE_PROPERTY(QDateTime, xAxisMin, setXAxisMin, {})
    QML_READABLE_PROPERTY(QDateTime, xAxisMax, setXAxisMax, {})
    QML_READABLE_PROPERTY(int, xAxisTickCount, setXAxisTickCount, 2)
    QML_READABLE_PROPERTY(qreal, yAxisMin, setYAxisMin, 0)
    QML_READABLE_PROPERTY(qreal, yAxisMax, setYAxisMax, 1)

    QML_READABLE_PROPERTY(QStringList, barMonths, setBarMonths, {})
    QML_READABLE_PROPERTY(QList<qreal>, barRevenue, setBarRevenue, {})
    QML_READABLE_PROPERTY(QList<qreal>, barNetIncome, setBarNetIncome, {})

    QML_READABLE_PROPERTY(double, conversionRate, setConversionRate, {})

public:
    enum CourveType { GROSS_INCOME_CURVE = 0,
                      EXPENSE_CURVE,
                      NET_INCOME_CURVE,
                      THRESHOLD_CURVE,
                      CURVE_COUNT };
    Q_ENUM(CourveType)

    explicit UiController(QObject *parent = nullptr);

    Q_INVOKABLE void setChartSeries(int index, QAbstractSeries *series);
    Q_INVOKABLE void generateRegistry();
    Q_INVOKABLE void openLedger(const QUrl &url);

    Q_INVOKABLE constexpr int invisibleColumns() const {
        return static_cast<int>(_settings->_invisibleColumns.size());
    }

    Q_INVOKABLE void updateCurrencyRate(QString const& date);

    constexpr Settings* settings() const { return _settings; }
    constexpr TableModel* tableModel() const { return _tableModel; }
    constexpr GitClient& gitClient() const { return *_gitClient; }

    void initGraph();
    void updateGraph(int rowIndex);
    void updateXAxis(const QDateTime &val);

signals:
    void error(const QString &msg, bool fatal);

private:
    void initBackup();

    void updateYAxis(qreal amount);
    void resetGraphLines();
    void resetGraphBars();

    void resetMinIncome();

    std::array<QXYSeries*, CURVE_COUNT> _chartSeries;
    Settings* _settings{};
    RestClient* _restClient{};
    TableModel* _tableModel{};
    std::unique_ptr<GitClient> _gitClient;
};
