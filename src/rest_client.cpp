#include "rest_client.h"
#include <QNetworkAccessManager>
#include <QRestAccessManager>
#include <QRestReply>
#include <QJsonDocument>
#include <QJsonObject>
#include <QUrlQuery>

// https://www.cursbnr.ro/api/doc.html

static const QString BNR_SERVER_URL{"https://www.cursbnr.ro/api/json.php"};

static constexpr char DATE_FIELD[]{"date"};
static constexpr char CURRENCY_FIELD[]{"currency"};
static constexpr char VALUE_FIELD[]{"value"};

RestClient::RestClient(QObject *parent)
    : QObject{parent},
    _accessManager{new QNetworkAccessManager(this)},
    _restManager(new QRestAccessManager(_accessManager, this))
{}

void RestClient::requestConversionRate(QString const& currency, QDate const& date)
{
    QUrlQuery urlQuery;
    urlQuery.addQueryItem("currency", currency);
    if (date.isValid()) {
        urlQuery.addQueryItem("date", date.toString("yyyy-MM-dd"));
    }
    QUrl url(BNR_SERVER_URL);
    url.setQuery(urlQuery);
    QNetworkRequest netReq(url);

    _restManager->get(netReq, this, [this](QRestReply &reply) {
        if (!reply.isSuccess()) {
            qWarning() << reply.errorString();
            return;
        }
        QJsonParseError error;
        if (auto const doc = reply.readJson(&error)) {
            parseReply(*doc);
            return;
        }
        qWarning() << error.errorString();
    });
}

void RestClient::parseReply(QJsonDocument const& doc)
{
    if (!doc.isObject()) {
        qWarning() << "Invalid JSON object" << doc;
        return;
    }
    auto const obj = doc.object();
    if (!obj.contains(DATE_FIELD) ||
        !obj.contains(CURRENCY_FIELD) ||
        !obj.contains(VALUE_FIELD)) {
        qWarning() << "Missing required JSON field" << doc;
        return;
    }
    auto const date = obj.value(DATE_FIELD).toString();
    auto const currency = obj.value(CURRENCY_FIELD).toString();
    auto const value = obj.value(VALUE_FIELD).toString();
    qInfo() << date << currency << "=" << value << "RON";

    bool ok{};
    auto const numericValue = value.toDouble(&ok);
    if (!ok) {
        qWarning() << "Cannot convert to double";
        return;
    }
    emit conversionRateReady(numericValue, currency);
}
