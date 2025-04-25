#ifndef OBDHANDLER_H
#define OBDHANDLER_H

#include <QObject>
#include <QMap>
#include <QString>
#include <QDebug>
#include <QProcess>

class OBDHandler : public QObject {
    Q_OBJECT

public:
    explicit OBDHandler(QObject *parent = nullptr);
    Q_INVOKABLE QString getErrorDescription(const QString &code);

private:
    void loadOBDCodes(const QString &filePath);
    QMap<QString, QMap<QString, QString>> obdCodes; // Nested map for codes
     QProcess *process = nullptr;
};

#endif // OBDHANDLER_H
