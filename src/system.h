#ifndef SYSTEM_H
#define SYSTEM_H

#include <QObject>
#include <QColor>
#include <QString>

#include <QtQml/qqmlregistration.h>

class QQmlEngine;
class QJSEngine;

class System : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    inline static System *instance;
    static void init(QObject *parent = nullptr) { instance = new System(parent); }
    static System *create(QQmlEngine *, QJSEngine *) { return instance; }

    bool checkDirs() const;

    Q_INVOKABLE static QString dataPath();
    Q_INVOKABLE static QString language();
    Q_INVOKABLE static QString locale();
    Q_INVOKABLE static QStringList translations();

    Q_INVOKABLE void startSpeechRecognizer() const;
    Q_INVOKABLE void setAlarm(int id, long long time, const QString &task) const;
    Q_INVOKABLE void cancelAlarm(int id) const;
    Q_INVOKABLE void updateStatusBarColor(bool darkTheme) const;
    Q_INVOKABLE void checkPermissions() const;

Q_SIGNALS:
    void speechRecognized(const QString &result);

private:
    explicit System(QObject *parent = nullptr);
    Q_DISABLE_COPY_MOVE(System)
};

#endif // SYSTEM_H
