#pragma once

#include <QObject>

class QNetworkAccessManager;
class QRestAccessManager;

class RestClient : public QObject
{
    Q_OBJECT
public:
    enum class Currency {EUR, USD};

    explicit RestClient(QObject *parent = nullptr);
    void requestConversionRate(QString const& currency, QDate const& date);

signals:
    void conversionRateReady(double value, QString const& currency);

private:
    void parseReply(QJsonDocument const& doc);

    QNetworkAccessManager* _accessManager{};
    QRestAccessManager* _restManager{};
};
