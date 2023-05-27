#ifndef APPDATA_H
#define APPDATA_H

#include <QObject>

#include <QtQml/qqmlregistration.h>

#include <QQmlObjectListModel.h>

#include "list.h"

class QQmlEngine;
class QJSEngine;

class AppData : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    QML_OBJMODEL_PROPERTY(lists, List)
    Q_PROPERTY(List *currentList READ currentList NOTIFY currentListChanged)
    Q_PROPERTY(bool drawerEnabled MEMBER m_drawerEnabled NOTIFY drawerEnabledChanged)

public:
    ~AppData();

    inline static AppData *instance;
    static void init(QObject *parent = nullptr) { instance = new AppData(parent); }
    static AppData *create(QQmlEngine *, QJSEngine *) { return instance; }

    Q_INVOKABLE void readListFile(const QString &path = QString());
    Q_INVOKABLE void writeListFile(const QString &path = QString()) const;

    int findList(const QString &name) const;

    Q_INVOKABLE bool addList(const QString &name) const;
    Q_INVOKABLE void selectList(const QString &name);
    Q_INVOKABLE void removeList(const QString &name);
    Q_INVOKABLE void removeList(int index);

    List *currentList() const;
    void setCurrentList(List *currentList);

Q_SIGNALS:
    void currentListChanged(List *currentList);
    void drawerEnabledChanged(bool drawerEnabled);

private:
    explicit AppData(QObject *parent = nullptr);
    Q_DISABLE_COPY_MOVE(AppData)

    QString m_listFilePath;

    List *m_currentList;
    bool m_drawerEnabled;
};

#endif // APPDATA_H
