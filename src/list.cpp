#include "list.h"

#include <QJsonArray>
#include "task.h"
#include "uniqueid.h"

List::List(const QString &name, QObject *parent)
    : QObject(parent)
    , m_name(name)
    , m_completedTasks(0)
    , m_hideCompleted(false)
    , m_sortByDueDate(false)
{
    m_tasks = new QQmlObjectListModel<Task>(this);
    m_sortedList = new SortFilterModel(this);
    m_sortedList->setSourceModel(m_tasks);
    connect(this, &List::hideCompletedChanged,
            m_sortedList, &SortFilterModel::setHideCompleted);
}

List *List::fromJson(const QJsonObject &json)
{
    auto c = new List(json["name"].toString());
    for (const auto task : json["tasks"].toArray())
        c->addTask(Task::fromJson(task.toObject()));
    c->setHideCompleted(json["hideCompleted"].toBool());
    c->setSortByDueDate(json["sortByDueDate"].toBool());
    return c;
}

QJsonObject List::toJson() const
{
    QJsonObject json;
    json["name"] = name();
    QJsonArray jarr;
    for (const auto &task : m_tasks->toList())
        jarr.append(task->toJson());
    json["tasks"] = jarr;
    json["hideCompleted"] = hideCompleted();
    json["sortByDueDate"] = sortByDueDate();
    return json;
}

Task *List::findTask(const QString &name) const
{
    for (const auto &i : m_tasks->toList()) {
        if (i->name() == name)
            return i;
    }
    return nullptr;
}

void List::addTask(Task *task)
{
    connect(task, &Task::checkedChanged,
            this, [=] (bool checked) {
        setCompletedTasks(completedTasks() + (checked ? 1 : -1));
    });
    connect(task, &Task::destroyed,
            this, [=] (QObject *obj) {
        auto task = static_cast<Task*>(obj);
        if (task->checked())
            setCompletedTasks(completedTasks() - 1);
    });
    if (task->checked())
        setCompletedTasks(completedTasks() + 1);
    m_tasks->append(task);
}

bool List::newTask(const QString &name)
{
    if (findTask(name))
        return false;
    addTask(new Task(name, UniqueID::newUID()));

    return true;
}

bool List::moveTask(int from, int to) const
{
    if (from >= 0 && from < m_tasks->count() &&
        to >= 0 && to < m_tasks->count()) {
        m_tasks->move(from, to);
        return true;
    }
    return false;
}

void List::removeChecked() const
{
    int i = 0;
    Task *task;

    while (i < m_tasks->count()) {
        task = m_tasks->at(i);
        if (task->checked())
            m_tasks->remove(task);
        else
            ++i;
    }
}

void List::removeAll() const
{
    m_tasks->clear();
}

void List::removeTask(const QString &name) const
{
    auto task = findTask(name);
    if (task)
        m_tasks->remove(task);
}

bool List::modifyTask(QObject *obj, const QString &name) const
{
    auto task = static_cast<Task*>(obj);
    if (findTask(name) && findTask(name) != task)
        return false;
    task->setName(name);
    return true;
}

//{{{ Properties getters/setters definitions

QString List::name() const
{
    return m_name;
}

void List::setName(const QString &name)
{
    if (m_name == name)
        return;

    m_name = name;
    emit nameChanged(m_name);
}

int List::completedTasks() const
{
    return m_completedTasks;
}

void List::setCompletedTasks(int completedTasks)
{
    if (m_completedTasks == completedTasks)
        return;

    m_completedTasks = completedTasks;
    emit completedTasksChanged(m_completedTasks);
}

bool List::hideCompleted() const
{
    return m_hideCompleted;
}

void List::setHideCompleted(bool hideCompleted)
{
    if (m_hideCompleted == hideCompleted)
        return;

    m_hideCompleted = hideCompleted;
    emit hideCompletedChanged(m_hideCompleted);
}

bool List::sortByDueDate() const
{
    return m_sortByDueDate;
}

void List::setSortByDueDate(bool sortByDueDate)
{
    if (m_sortByDueDate == sortByDueDate)
        return;

    m_sortByDueDate = sortByDueDate;
    emit sortByDueDateChanged(m_sortByDueDate);
}

SortFilterModel *List::sortedList() const
{
    return m_sortedList;
}

void List::setSortedList(SortFilterModel *sortedList)
{
    if (m_sortedList == sortedList)
        return;

    m_sortedList = sortedList;
    emit sortedListChanged(m_sortedList);
}

//}}} Properties getters/setters definitions
