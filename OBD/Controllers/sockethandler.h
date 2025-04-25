#ifndef SOCKETHANDLER_H
#define SOCKETHANDLER_H

#include <QObject>
#include <QTcpSocket>
#include <QTcpServer>

class SocketHandler : public QObject
{
    Q_OBJECT
public:
    explicit SocketHandler(QObject *parent = nullptr);
    ~SocketHandler();

    Q_INVOKABLE void startServer(quint16 port);
    Q_INVOKABLE void sendToSocket(const QString &text);
    Q_INVOKABLE void sendOnly(const QString &text);


signals:
    void messageReceived(const QString &text);      // Signal to send message to QML
    void audioReceived(const QString &audio);


private slots:
    void onNewConnection();
    void onReadyRead();
    void onDisconnected();

private:
    QTcpSocket *socket;
    QTcpServer *server;
};

#endif // SOCKETHANDLER_H
