#include "list.h"

#include <QJsonArray>
#include <QRegularExpression>

#include "uniqueid.h"

List::List(const QString &name, QObject *parent)
    : QObject(parent)
    , m_visualModel(new QQmlObjectListModel<Task>(this))
    , m_searchModel(new QQmlObjectListModel<Task>(this))
    , m_name(name)
    , m_completedTasksCount(0)
    , m_hideCompleted(false)
    , m_ordering(Order::UserReorder)
    , m_visualModelSorted(new SortFilterModel(this))
{
    m_visualModelSorted->setSourceModel(m_visualModel);
}

List *List::fromJson(const QJsonObject &json)
{
    List *list = new List(json["name"].toString());
    for (const QJsonValue &jsonTask : json["tasks"].toArray())
        list->addTask(Task::fromJson(jsonTask.toObject()));
    list->setHideCompleted(json["hideCompleted"].toBool());
    list->setOrdering(List::Order(json["ordering"].toInt()));
    return list;
}

QJsonObject List::toJson() const
{
    QJsonObject json;
    json["name"] = name();
    QJsonArray jarr;
    for (const Task *task : m_tasks)
        jarr.append(task->toJson());
    json["tasks"] = jarr;
    json["hideCompleted"] = hideCompleted();
    json["ordering"] = ordering();
    return json;
}

Task *List::findTask(const QString &name) const
{
    for (Task *task : m_tasks) {
        if (task->name() == name)
            return task;
    }
    return nullptr;
}

void List::addTask(Task *task)
{
    connect(task, &Task::completedChanged, this, [this, task](bool completed) {
        if (completed) {
            setCompletedTasksCount(completedTasksCount() + 1);
            if (hideCompleted() && m_visualModel->contains(task))
                m_visualModel->remove(task);
        } else {
            setCompletedTasksCount(completedTasksCount() - 1);
            if (!m_visualModel->contains(task)) {
                int index = m_tasks.indexOf(task);
                while (index > 0) {
                    if (m_visualModel->contains(m_tasks.at(index - 1)))
                        break;
                    index--;
                }
                m_visualModel->insert(index, task);
            }
        }
    });
    task->setParent(this);
    if (task->completed())
        setCompletedTasksCount(completedTasksCount() + 1);
    m_tasks.append(task);
    m_visualModel->append(task);
    Q_EMIT tasksCountChanged(m_tasks.count());
}

bool List::newTask(const QString &name)
{
    if (findTask(name))
        return false;
    addTask(new Task(name, UniqueID::newUID(), this));
    return true;
}

bool List::moveTask(int from, int to)
{
    if (from != to
        && from >= 0 && from < m_visualModel->count()
        && to >= 0 && to < m_visualModel->count()) {
        m_tasks.move(m_tasks.indexOf(m_visualModel->get(from)),
                     m_tasks.indexOf(m_visualModel->get(to)));
        m_visualModel->move(from, to);
        return true;
    }
    return false;
}

void List::removeCompleted()
{
    int i = 0;
    while (i < m_tasks.count()) {
        Task *task = m_tasks.at(i);
        if (task->completed())
            removeTask(task);
        else
            ++i;
    }
}

void List::removeAll()
{
    if (m_tasks.count()) {
        for (Task *task : m_tasks)
            task->deleteLater();
        m_tasks.clear();
        m_visualModel->clear();
        setCompletedTasksCount(0);
        Q_EMIT tasksCountChanged(0);
    }
}

void List::removeTask(QObject *obj)
{
    Task *task = qobject_cast<Task *>(obj);
    if (task) {
        if (task->completed())
            setCompletedTasksCount(completedTasksCount() - 1);
        m_tasks.removeOne(task);
        m_visualModel->remove(task);
        task->deleteLater();
        Q_EMIT tasksCountChanged(m_tasks.count());
    }
}

void List::removeTask(int id)
{
    for (Task *task : m_tasks) {
        if (task->id() == id) {
            removeTask(task);
            return;
        }
    }
}

void List::removeTask(const QString &name)
{
    removeTask(findTask(name));
}

bool List::renameTask(QObject *obj, const QString &name) const
{
    Task *task = qobject_cast<Task *>(obj);
    Task *tmp = findTask(name);
    if (tmp && tmp != task)
        return false;
    task->setName(name);
    return true;
}

void List::completeAll() const
{
    for (Task *task : m_tasks)
        task->setCompleted(true);
}

void List::uncompleteAll() const
{
    for (Task *task : m_tasks)
        task->setCompleted(false);
}

void List::filterTasks(const QString &term)
{
    m_searchModel->clear();

    if (term.isEmpty())
        return;

    QRegularExpression re(term);
    for (Task *task : m_tasks) {
        QRegularExpressionMatch match(re.match(task->name()));
        if (match.hasPartialMatch() || match.hasMatch()) {
            if (!m_searchModel->contains(task))
                m_searchModel->append(task);
        // } else if (m_searchModel->contains(task)) {
            // m_searchModel->remove(task);
        }
    }
}

QString List::name() const
{
    return m_name;
}

void List::setName(const QString &name)
{
    if (m_name == name)
        return;

    m_name = name;
    Q_EMIT nameChanged(m_name);
}

int List::tasksCount() const
{
    return m_tasks.count();
}

int List::completedTasksCount() const
{
    return m_completedTasksCount;
}

void List::setCompletedTasksCount(int completedTasksCount)
{
    if (m_completedTasksCount == completedTasksCount)
        return;

    m_completedTasksCount = completedTasksCount;
    Q_EMIT completedTasksCountChanged(completedTasksCount);
}

bool List::hideCompleted() const
{
    return m_hideCompleted;
}

void List::setHideCompleted(bool hideCompleted)
{
    if (m_hideCompleted == hideCompleted)
        return;

    if (hideCompleted) {
        int i = 0;
        while (i < m_visualModel->count()) {
            Task *task = m_visualModel->at(i);
            if (task->completed())
                m_visualModel->remove(task);
            else
                ++i;
        }
    } else {
        for (int i = 0; i < m_tasks.count(); i++) {
            Task *task = m_tasks.at(i);
            if (task->completed())
                m_visualModel->insert(i, task);
        }
    }

    m_hideCompleted = hideCompleted;
    Q_EMIT hideCompletedChanged(m_hideCompleted);
}

List::Order List::ordering() const
{
    return m_ordering;
}

void List::setOrdering(Order ordering)
{
    if (m_ordering == ordering)
        return;

    switch (ordering) {
    case Order::UserReorder: break;
    case Order::AlphabeticalInc: m_visualModelSorted->setCompareFunction(alphabeticalInc); break;
    case Order::AlphabeticalDec: m_visualModelSorted->setCompareFunction(alphabeticalDec); break;
    case Order::CreatedInc: m_visualModelSorted->setCompareFunction(createdInc); break;
    case Order::CreatedDec: m_visualModelSorted->setCompareFunction(createdDec); break;
    case Order::DueInc: m_visualModelSorted->setCompareFunction(dueInc); break;
    case Order::DueDec: m_visualModelSorted->setCompareFunction(dueDec); break;
    case Order::CompletedInc: m_visualModelSorted->setCompareFunction(completedInc); break;
    case Order::CompletedDec: m_visualModelSorted->setCompareFunction(completedDec); break;
    }

    m_ordering = ordering;
    Q_EMIT orderingChanged(m_ordering);
}

SortFilterModel *List::visualModelSorted() const
{
    return m_visualModelSorted;
}
