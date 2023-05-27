#ifndef LIST_H
#define LIST_H

#include <QObject>

#include <QtQml/qqmlregistration.h>

#include <QQmlObjectListModel.h>

#include "sortfiltermodel.h"
#include "task.h"

class List : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("")

    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(int tasksCount READ tasksCount NOTIFY tasksCountChanged)
    Q_PROPERTY(int completedTasksCount READ completedTasksCount NOTIFY completedTasksCountChanged)
    Q_PROPERTY(bool hideCompleted READ hideCompleted WRITE setHideCompleted NOTIFY hideCompletedChanged)
    Q_PROPERTY(Order ordering READ ordering WRITE setOrdering NOTIFY orderingChanged)

    QML_OBJMODEL_PROPERTY(visualModel, Task)
    QML_OBJMODEL_PROPERTY(searchModel, Task)
    Q_PROPERTY(SortFilterModel *visualModelSorted READ visualModelSorted CONSTANT)

public:
    enum Order {
        UserReorder,
        AlphabeticalInc,
        AlphabeticalDec,
        CreatedInc,
        CreatedDec,
        DueInc,
        DueDec,
        CompletedInc,
        CompletedDec
    };
    Q_ENUM(Order)

    explicit List(const QString &name, QObject *parent = nullptr);

    static List *fromJson(const QJsonObject &json);
    QJsonObject toJson() const;

    void addTask(Task *task);

    Q_INVOKABLE Task *findTask(const QString &name) const;
    Q_INVOKABLE bool newTask(const QString &name);
    Q_INVOKABLE bool moveTask(int from, int to);
    Q_INVOKABLE void removeCompleted();
    Q_INVOKABLE void removeAll();
    Q_INVOKABLE void removeTask(QObject *obj);
    Q_INVOKABLE void removeTask(int id);
    Q_INVOKABLE void removeTask(const QString &name);
    Q_INVOKABLE bool renameTask(QObject *obj, const QString &name) const;
    Q_INVOKABLE void completeAll() const;
    Q_INVOKABLE void uncompleteAll() const;

    Q_INVOKABLE void filterTasks(const QString &term);

    QString name() const;
    void setName(const QString &name);

    int tasksCount() const;

    int completedTasksCount() const;

    bool hideCompleted() const;
    void setHideCompleted(bool hideCompleted);

    Order ordering() const;
    void setOrdering(Order ordering);

    SortFilterModel *visualModelSorted() const;

Q_SIGNALS:
    void nameChanged(const QString &name);
    void tasksCountChanged(int tasksCount);
    void completedTasksCountChanged(int completedTasksCount);
    void hideCompletedChanged(bool hideCompleted);
    void orderingChanged(Order ordering);

private:
    void setCompletedTasksCount(int completedTasksCount);

    QString m_name;
    int m_completedTasksCount;
    bool m_hideCompleted;
    Order m_ordering;

    QList<Task *> m_tasks;
    SortFilterModel *m_visualModelSorted;
};

#endif // LIST_H
