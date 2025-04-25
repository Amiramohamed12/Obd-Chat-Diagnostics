#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QtWebEngineQuick/QtWebEngineQuick>
#include <QQmlContext>
#include <QDebug>
#include <QProcess>
#include "Controllers/sockethandler.h"
#include "Controllers/OBDHandler.h"

int main(int argc, char *argv[])
{
    qputenv("QT_IM_MODULE", QByteArray("qtvirtualkeyboard"));

    QGuiApplication app(argc, argv);
    QQmlApplicationEngine engine;

    qmlRegisterType<SocketHandler>("SocketHandler", 1, 0, "SocketHandler");

    // Start the chatbot script
    QProcess::startDetached("/bin/bash", QStringList() << "-c" << "python3 /home/ayat/Desktop/comm/voice1_chatbot.py > /dev/null 2>&1 & disown");

    // Handle object creation failure
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);

    engine.loadFromModule("OBD", "Main");

    // Register handlers
    SocketHandler socketHandler;
    engine.rootContext()->setContextProperty("socketHandler", &socketHandler);

    OBDHandler obdHandler;
    engine.rootContext()->setContextProperty("obdHandler", &obdHandler);

    // Kill the process on port 5600 using fuser when the app exits
    QObject::connect(&app, &QCoreApplication::aboutToQuit, []() {
        int portToKill = 5600;
        qDebug() << "🛑 Releasing port using fuser: " << portToKill;
        QProcess::execute("/bin/sh", QStringList() << "-c" << QString("fuser -k %1/tcp").arg(portToKill));
    });

    return app.exec();
}
