#include "wagnis.h"
#include <openssl/conf.h>
#include <openssl/evp.h>
#include <openssl/err.h>

#include <QDebug>
#include <QFile>
#include <QUrl>
#include <QUrlQuery>
#include <QUuid>
#include <QCryptographicHash>
#include <QJsonDocument>
#include <QJsonObject>

Wagnis::Wagnis(QNetworkAccessManager *manager, const QString &applicationName, const QString applicationVersion, QObject *parent) : QObject(parent)
{
    qDebug() << "Initializing Wagnis...";
    this->manager = manager;
    this->applicationName = applicationName;
    this->applicationVersion = applicationVersion;
    getIpInfo();

    /* Load the human readable error strings for libcrypto */
    ERR_load_crypto_strings();
    /* Load all digest and cipher algorithms */
    OpenSSL_add_all_algorithms();
    /* Load config file, and other important initialisation */
    OPENSSL_config(NULL);

    generateId();
}

Wagnis::~Wagnis()
{
    qDebug() << "Shutting down Wagnis...";
    /* Removes all digests and ciphers */
    EVP_cleanup();

    /* if you omit the next, a small leak may be left when you make use of the BIO (low level API) for e.g. base64 transformations */
    CRYPTO_cleanup_all_ex_data();

    /* Remove error strings */
    ERR_free_strings();
}

QString Wagnis::getId()
{
    return this->wagnisId;
}

void Wagnis::registerApplication()
{
    qDebug() << "Wagnis::registerApplication";
    QUrl url = QUrl(API_REGISTRATION);
    QNetworkRequest request(url);
    request.setHeader(QNetworkRequest::ContentTypeHeader, MIME_TYPE_JSON);

    QJsonObject jsonPayloadObject;
    jsonPayloadObject.insert("id", wagnisId);
    jsonPayloadObject.insert("country", ipInfo.value("country").toString());
    jsonPayloadObject.insert("application", this->applicationName);
    jsonPayloadObject.insert("version", this->applicationVersion);

    QJsonDocument requestDocument(jsonPayloadObject);
    QByteArray jsonAsByteArray = requestDocument.toJson();
    request.setHeader(QNetworkRequest::ContentLengthHeader, QByteArray::number(jsonAsByteArray.size()));

    QNetworkReply *reply = manager->post(request, jsonAsByteArray);

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(handleRegisterApplicationError(QNetworkReply::NetworkError)));
    connect(reply, SIGNAL(finished()), this, SLOT(handleRegisterApplicationFinished()));
}

void Wagnis::getApplicationRegistration()
{
    qDebug() << "Wagnis::getApplicationRegistration";
    QUrl url = QUrl(API_REGISTRATION);
    QUrlQuery urlQuery = QUrlQuery();
    urlQuery.addQueryItem("id", this->wagnisId);
    urlQuery.addQueryItem("application", this->applicationName);
    url.setQuery(urlQuery);
    QNetworkRequest request(url);

    QNetworkReply *reply = manager->get(request);

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(handleGetApplicationRegistrationError(QNetworkReply::NetworkError)));
    connect(reply, SIGNAL(finished()), this, SLOT(handleRegisterApplicationFinished()));
}

bool Wagnis::isRegistered()
{
    // TODO: Implement the critical stuff here... ;)
    return false;
}

void Wagnis::generateId()
{
    // We try to use the unique device ID. If we can't determine this ID, a random key is used...
    // Unique device ID determination copied from the QtSystems module of the Qt Toolkit
    QString temporaryUUID;
    if (temporaryUUID.isEmpty()) {
        QFile file(QStringLiteral("/sys/devices/virtual/dmi/id/product_uuid"));
        if (file.open(QIODevice::ReadOnly)) {
            QString id = QString::fromLocal8Bit(file.readAll().simplified().data());
            if (id.length() == 36) {
                temporaryUUID = id;
            }
            file.close();
        }
    }
    if (temporaryUUID.isEmpty()) {
        QFile file(QStringLiteral("/etc/machine-id"));
        if (file.open(QIODevice::ReadOnly)) {
            QString id = QString::fromLocal8Bit(file.readAll().simplified().data());
            if (id.length() == 32) {
                temporaryUUID = id.insert(8,'-').insert(13,'-').insert(18,'-').insert(23,'-');
            }
            file.close();
        }
    }
    if (temporaryUUID.isEmpty()) {
        QFile file(QStringLiteral("/etc/unique-id"));
        if (file.open(QIODevice::ReadOnly)) {
            QString id = QString::fromLocal8Bit(file.readAll().simplified().data());
            if (id.length() == 32) {
                temporaryUUID = id.insert(8,'-').insert(13,'-').insert(18,'-').insert(23,'-');
            }
            file.close();
        }
    }
    if (temporaryUUID.isEmpty()) {
        QFile file(QStringLiteral("/var/lib/dbus/machine-id"));
        if (file.open(QIODevice::ReadOnly)) {
            QString id = QString::fromLocal8Bit(file.readAll().simplified().data());
            if (id.length() == 32) {
                temporaryUUID = id.insert(8,'-').insert(13,'-').insert(18,'-').insert(23,'-');
            }
            file.close();
        }
    }
    if (temporaryUUID.isEmpty()) {
        qDebug() << "FATAL: Unable to obtain unique device ID!";
        temporaryUUID = "n/a";
    }

    QCryptographicHash idHash(QCryptographicHash::Sha256);
    idHash.addData(temporaryUUID.toUtf8());
    idHash.addData("Piepmatz");
    idHash.result().toHex();

    QString uidHash = QString::fromUtf8(idHash.result().toHex());
    qDebug() << "Hash: " + uidHash;
    wagnisId = uidHash.left(4) + "-" + uidHash.mid(4,4) + "-" + uidHash.mid(8,4) + "-" + uidHash.mid(12,4);
    qDebug() << "[Wagnis] ID: " + wagnisId;
}

void Wagnis::getIpInfo()
{
    qDebug() << "Wagnis::getIpInfo";
    QUrl url = QUrl("https://ipinfo.io/json");
    QNetworkRequest request(url);
    QNetworkReply *reply = manager->get(request);

    connect(reply, SIGNAL(error(QNetworkReply::NetworkError)), this, SLOT(handleGetIpInfoError(QNetworkReply::NetworkError)));
    connect(reply, SIGNAL(finished()), this, SLOT(handleGetIpInfoFinished()));
}

void Wagnis::handleGetIpInfoError(QNetworkReply::NetworkError error)
{
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    qWarning() << "Wagnis::handleGetIpInfoError:" << (int)error << reply->errorString() << reply->readAll();
}

void Wagnis::handleGetIpInfoFinished()
{
    qDebug() << "Wagnis::handleGetIpInfoFinished";
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        return;
    }

    QJsonDocument jsonDocument = QJsonDocument::fromJson(reply->readAll());
    if (jsonDocument.isObject()) {
        QJsonObject responseObject = jsonDocument.object();
        this->ipInfo = responseObject.toVariantMap();
        qDebug() << "[Wagnis] Country: " + ipInfo.value("country").toString();
    }
}

void Wagnis::handleRegisterApplicationError(QNetworkReply::NetworkError error)
{
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    qWarning() << "Wagnis::handleRegisterApplicationError:" << (int)error << reply->errorString() << reply->readAll();
    if (error == QNetworkReply::ContentConflictError) { // Conflict = Registration already there!
        qDebug() << "[Wagnis] Installation already registered!";
        this->getApplicationRegistration();
    } else {
        emit registrationError(QString::number((int)error) + "Return code: " + " - " + reply->errorString());
    }
}

void Wagnis::handleRegisterApplicationFinished()
{
    qDebug() << "Wagnis::handleRegisterApplicationFinished";
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    reply->deleteLater();
    if (reply->error() != QNetworkReply::NoError) {
        return;
    }

    QJsonDocument jsonDocument = QJsonDocument::fromJson(reply->readAll());
    if (jsonDocument.isObject()) {
        QJsonObject responseObject = jsonDocument.object();
        QVariantMap registrationInformation = responseObject.toVariantMap();
        qDebug() << "Payload: " << registrationInformation.value("registration").toString();
        qDebug() << "Signature: " << registrationInformation.value("signature").toString();
        // TODO: Signature validation comes here... Send signals for success and failure!
    }
}

void Wagnis::handleGetApplicationRegistrationError(QNetworkReply::NetworkError error)
{
    QNetworkReply *reply = qobject_cast<QNetworkReply *>(sender());
    qWarning() << "Wagnis::handleGetApplicationRegistrationError:" << (int)error << reply->errorString() << reply->readAll();
    emit registrationError(QString::number((int)error) + "Return code: " + " - " + reply->errorString());
}
