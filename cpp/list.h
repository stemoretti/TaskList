#ifndef LIST_H
#define LIST_H

#include <QObject>
#include <QSortFilterProxyModel>

#include "QQmlObjectListModel.h"
#include "sortfiltermodel.h"

class Task;

class List : public QObject
{
    Q_OBJECT

    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    QML_OBJMODEL_PROPERTY(tasks, Task)
    Q_PROPERTY(int completedTasks READ completedTasks WRITE setCompletedTasks NOTIFY completedTasksChanged)
    Q_PROPERTY(bool hideCompleted READ hideCompleted WRITE setHideCompleted NOTIFY hideCompletedChanged)
    Q_PROPERTY(bool sortByDueDate READ sortByDueDate WRITE setSortByDueDate NOTIFY sortByDueDateChanged)
    Q_PROPERTY(SortFilterModel *sortedList READ sortedList NOTIFY sortedListChanged)

public:
    explicit List(const QString &name, QObject *parent = nullptr);

    static List *fromJson(const QJsonObject &json);
    QJsonObject toJson() const;

    Q_INVOKABLE
    Task *findTask(const QString &name) const;
    void addTask(Task *task);

    //{{{ Properties getters declarations

    QString name() const;
    int completedTasks() const;
    bool hideCompleted() const;
    bool sortByDueDate() const;
    SortFilterModel *sortedList() const;

    //}}} Properties getters declarations

signals:
    //{{{ Properties signals

    void nameChanged(QString name);
    void completedTasksChanged(int completedTasks);
    void hideCompletedChanged(bool hideCompleted);
    void sortByDueDateChanged(bool sortByDueDate);
    void sortedListChanged(SortFilterModel *sortedList);

    //}}} Properties signals

public slots:
    bool addTask(const QString &name);
    void removeChecked() const;
    void removeAll() const;
    void removeTask(const QString &name) const;
    bool modifyTask(QObject *obj, const QString &name) const;
    bool moveTask(int from, int to) const;

    //{{{ Properties setters declarations

    void setName(const QString &name);
    void setCompletedTasks(int completedTasks);
    void setHideCompleted(bool hideCompleted);
    void setSortByDueDate(bool sortByDueDate);
    void setSortedList(SortFilterModel *sortedList);

    //}}} Properties setters declarations

private:
    //{{{ Properties declarations

    QString m_name;
    int m_completedTasks;
    bool m_hideCompleted;
    bool m_sortByDueDate;
    SortFilterModel *m_sortedList;

    //}}} Properties declarations
};

#endif // LIST_H
