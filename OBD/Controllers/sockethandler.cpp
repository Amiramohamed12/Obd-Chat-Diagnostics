#include "sockethandler.h"
#include <QDebug>
#include <QTcpSocket>
#include <QTcpServer>

SocketHandler::SocketHandler(QObject *parent)
    : QObject(parent), socket(new QTcpSocket(this)), server(new QTcpServer(this)) {
    connect(server, &QTcpServer::newConnection, this, &SocketHandler::onNewConnection);
}

SocketHandler::~SocketHandler() {
    if (socket->isOpen()) {
        socket->close();
    }
    delete server;
}

void SocketHandler::startServer(quint16 port) {
    if (server->listen(QHostAddress::Any, port)) {
        qDebug() << "Server started on port" << port;
    } else {
        qWarning() << "Failed to start the server!";
    }
}

void SocketHandler::sendToSocket(const QString &text) {
    socket->connectToHost("127.0.0.1", 5000);

    if (socket->waitForConnected(3000)) {
        qDebug() << "Connected to Python server!";

        socket->write((text + "\n").toUtf8());
        socket->flush();
        socket->waitForBytesWritten(1000);

        if (socket->waitForReadyRead(6000)) {
            QString response = socket->readAll().trimmed();  // Read response
            qDebug() << "Python server response:" << response;

            // Check if the response is an audio transcription
            if (response.startsWith("AUDIO_TEXT:")) {
                QString audio_text = response.mid(11).trimmed(); // Extract actual text
                qDebug() << "The user recorded:" << audio_text;
                emit audioReceived(audio_text);
            } else {
                emit messageReceived(response);
            }
        } else {
            qWarning() << "No response from Python server!";
        }
    } else {
        qWarning() << "Failed to connect to Python server!";
    }
}

void SocketHandler::sendOnly(const QString &text){
    socket->connectToHost("127.0.0.1", 5600);

    if (socket->waitForConnected(3000)) {
        qDebug() << "Connected to Python server!";

        socket->write((text + "\n").toUtf8());
        socket->flush();
        socket->waitForBytesWritten(1000);
    }else {
            qWarning() << "Failed to connect to Python server!";
        }

}

void SocketHandler::onNewConnection() {
    QTcpSocket *clientSocket = server->nextPendingConnection();

    connect(clientSocket, &QTcpSocket::readyRead, this, &SocketHandler::onReadyRead);
    connect(clientSocket, &QTcpSocket::disconnected, this, &SocketHandler::onDisconnected);

    qDebug() << "Client connected!";
}

void SocketHandler::onReadyRead() {
    QTcpSocket *clientSocket = qobject_cast<QTcpSocket *>(sender());
    if (clientSocket) {
        QByteArray data = clientSocket->readAll();
        qDebug() << "Received from client:" << data;

       // emit messageReceived(QString::fromUtf8(data));  // Emit signal for QML
    }
}

void SocketHandler::onDisconnected() {
    QTcpSocket *clientSocket = qobject_cast<QTcpSocket *>(sender());
    if (clientSocket) {
        qDebug() << "Client disconnected!";
        clientSocket->deleteLater();
    }
}
