#ifndef APPDATA_H
#define APPDATA_H

#include <QObject>
#include "QQmlObjectListModel.h"
#include "list.h"

class Task;

class AppData : public QObject
{
    Q_OBJECT

    QML_OBJMODEL_PROPERTY(lists, List)
    Q_PROPERTY(List *currentList READ currentList NOTIFY currentListChanged)

public:
    virtual ~AppData();

    static AppData &instance();

    bool checkDirs() const;

    void readListFile();
    void writeListFile() const;

    List *findList(const QString &name) const;

#ifdef Q_OS_ANDROID
    Q_INVOKABLE
    void startSpeechRecognizer() const;

    Q_INVOKABLE
    void setAlarm(int id, long long time, const QString &task) const;

    Q_INVOKABLE
    void cancelAlarm(int id) const;
#endif

    //{{{ Properties getters/setters declarations

    List *currentList() const;
    void setCurrentList(List *currentList);

    //}}} Properties getters/setters declarations

signals:
#ifdef Q_OS_ANDROID
    void speechRecognized(const QString &result);
#endif

    //{{{ Properties signals

    void currentListChanged(List * currentList);

    //}}} Properties signals

public slots:
    bool addList(const QString &name) const;
    void selectList(const QString &name);
    void removeList(const QString &name);
    void removeList(int index);

private:
    explicit AppData(QObject *parent = nullptr);
    Q_DISABLE_COPY(AppData)

    QString m_listFilePath;

    //{{{ Properties declarations

    List *m_currentList;

    //}}} Properties declarations
};

#endif // APPDATA_H
