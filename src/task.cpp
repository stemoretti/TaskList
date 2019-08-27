#include "task.h"

Task::Task(const QString &name, int id, QObject *parent)
    : QObject(parent)
    , m_id(id)
    , m_name(name)
    , m_checked(false)
    , m_created(QDateTime::currentDateTime())
    , m_alarm(AlarmMode::NoAlarm)
{
    connect(this, &Task::checkedChanged,
            this, [=] (bool checked) {
        if (checked)
            setCompleted(QDateTime::currentDateTime());
        else
            setCompleted(QDateTime());
    });
}

Task *Task::fromJson(const QJsonObject &json)
{
    auto c = new Task;
    c->setId(json["id"].toInt());
    c->setName(json["name"].toString());
    c->setChecked(json["checked"].toBool());
    c->setCreated(QDateTime::fromString(json["created"].toString(), Qt::ISODate));
    c->setNotes(json["notes"].toString());
    c->setDueDate(QDate::fromString(json["dueDate"].toString(), "yyyy-MM-dd"));
    c->setDueTime(QTime::fromString(json["dueTime"].toString(), "hh:mm:ss"));
    c->setAlarm(AlarmMode(json["alarm"].toInt()));
    c->setCompleted(QDateTime::fromString(json["completed"].toString(), Qt::ISODate));
    return c;
}

QJsonObject Task::toJson() const
{
    QJsonObject json;
    json["id"] = id();
    json["name"] = name();
    json["checked"] = checked();
    json["created"] = created().toString(Qt::ISODate);
    json["notes"] = notes();
    json["dueDate"] = dueDate().toString("yyyy-MM-dd");
    json["dueTime"] = dueTime().toString("hh:mm:ss");
    json["alarm"] = alarm();
    json["completed"] = completed().toString(Qt::ISODate);
    return json;
}

//{{{ Properties getters/setters definitions

int Task::id() const
{
    return m_id;
}

void Task::setId(int id)
{
    if (m_id == id)
        return;

    m_id = id;
    emit idChanged(m_id);
}

QString Task::name() const
{
    return m_name;
}

void Task::setName(const QString &name)
{
    if (m_name == name)
        return;

    m_name = name;
    emit nameChanged(m_name);
}

bool Task::checked() const
{
    return m_checked;
}

void Task::setChecked(bool checked)
{
    if (m_checked == checked)
        return;

    m_checked = checked;
    emit checkedChanged(m_checked);
}

QDateTime Task::created() const
{
    return m_created;
}

void Task::setCreated(const QDateTime &created)
{
    if (m_created == created)
        return;

    m_created = created;
    emit createdChanged(m_created);
}

QString Task::notes() const
{
    return m_notes;
}

void Task::setNotes(const QString &notes)
{
    if (m_notes == notes)
        return;

    m_notes = notes;
    emit notesChanged(m_notes);
}

QDate Task::dueDate() const
{
    return m_dueDate;
}

void Task::setDueDate(const QDate &dueDate)
{
    if (m_dueDate == dueDate)
        return;

    m_dueDate = dueDate;
    emit dueDateChanged(m_dueDate);
}

QTime Task::dueTime() const
{
    return m_dueTime;
}

void Task::setDueTime(const QTime &dueTime)
{
    if (m_dueTime == dueTime)
        return;

    m_dueTime = dueTime;
    emit dueTimeChanged(m_dueTime);
}
Task::AlarmMode Task::alarm() const
{
    return m_alarm;
}

void Task::setAlarm(AlarmMode alarm)
{
    if (m_alarm == alarm)
        return;

    m_alarm = alarm;
    emit alarmChanged(m_alarm);
}

QDateTime Task::completed() const
{
    return m_completed;
}

void Task::setCompleted(const QDateTime &completed)
{
    if (m_completed == completed)
        return;

    m_completed = completed;
    emit completedChanged(m_completed);
}

//}}} Properties getters/setters definitions
