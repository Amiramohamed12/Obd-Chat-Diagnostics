#include "OBDHandler.h"
#include <QJsonDocument>
#include <QJsonObject>
#include <QJsonArray>
#include <QFile>
#include <QDebug>
#include <QProcess>

OBDHandler::OBDHandler(QObject *parent) : QObject(parent) {
    loadOBDCodes("/home/amira/obd-trouble-codes.json"); // Use the correct path to your JSON file
    process = new QProcess(this);
}

QString OBDHandler::getErrorDescription(const QString &code) {
    if (code.isEmpty()) {
        return "Unknown code";
    }

    QString charCode = code.at(0);
    QString specificCode = code.mid(1);

    if (obdCodes.contains(charCode)) {
        const QMap<QString, QString> &innerMap = obdCodes[charCode];


        if (innerMap.contains(specificCode)) {
            return innerMap[specificCode];
        }
    }

    return "Unknown code";
}


void OBDHandler::loadOBDCodes(const QString &filePath) {
    QFile file(filePath);

    // Check if the file exists and can be opened
    if (!file.exists()) {
        qWarning() << "The OBD codes file does not exist at:" << filePath;
        return;
    }

    if (!file.open(QIODevice::ReadOnly)) {
        qWarning() << "Couldn't open the JSON file:" << filePath;
        return;
    }

    QByteArray jsonData = file.readAll();
    QJsonDocument jsonDoc = QJsonDocument::fromJson(jsonData);

    // Check if the JSON document is valid
    if (jsonDoc.isNull() || !jsonDoc.isArray()) {
        qWarning() << "Invalid JSON format. Expected an array of OBD codes.";
        return;
    }

    QJsonArray jsonArray = jsonDoc.array();

    // Parse the JSON structure into the map
    for (const QJsonValue &value : jsonArray) {
        QJsonObject jsonObj = value.toObject();
        QString code = jsonObj["code"].toString();
        QString description = jsonObj["description"].toString();

        if (!code.isEmpty() && !description.isEmpty()) {
            QString charCode = code.at(0); // First character (e.g., 'P')
            QString specificCode = code.mid(1); // The rest of the code (e.g., '0100')

            // Store the description in the nested map
            obdCodes[charCode][specificCode] = description;
        }
    }


}
