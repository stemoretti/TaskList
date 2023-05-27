#include "task.h"

#include <QString>

Task::Task(const QString &name, int id, QObject *parent)
    : QObject(parent)
    , m_id(id)
    , m_name(name)
    , m_allDay(false)
    , m_reminder(Reminder::Off)
    , m_reminderType(ReminderType::Notification)
    , m_repeat(Repeat::Off)
    , m_created(QDateTime::currentDateTime())
{
}

Task *Task::fromJson(const QJsonObject &json)
{
    Task *task = new Task;
    task->setId(json["id"].toInt());
    task->setName(json["name"].toString());
    task->setNotes(json["notes"].toString());
    task->setAllDay(json["allDay"].toBool());
    task->setReminder(Reminder(json["reminder"].toInt()));
    task->setReminderType(ReminderType(json["reminderType"].toInt()));
    task->setRepeat(Repeat(json["repeat"].toInt()));
    task->setCreatedDateTime(json["created"].toString());
    task->setDueDateTime(json["due"].toString());
    task->setCompletedDateTime(json["completed"].toString());

    return task;
}

QJsonObject Task::toJson() const
{
    QJsonObject json;
    json["id"] = id();
    json["name"] = name();
    json["notes"] = notes();
    json["allDay"] = allDay();
    json["reminder"] = int(reminder());
    json["reminderType"] = int(reminderType());
    json["repeat"] = int(repeat());
    json["created"] = m_created.toString(Qt::ISODate);
    json["due"] = m_due.toString(Qt::ISODate);
    json["completed"] = m_completed.toString(Qt::ISODate);

    return json;
}

int Task::id() const
{
    return m_id;
}

void Task::setId(int id)
{
    if (m_id == id)
        return;

    m_id = id;
    Q_EMIT idChanged(id);
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
    Q_EMIT nameChanged(name);
}

bool Task::completed() const
{
    return m_completed.isValid();
}

void Task::setCompleted(bool completed)
{
    if (m_completed.isValid() == completed)
        return;

    setCompletedDateTime(completed ? QDateTime::currentDateTime().toString(Qt::ISODate) : "");
    Q_EMIT completedChanged(completed);
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
    Q_EMIT notesChanged(notes);
}

bool Task::allDay() const
{
    return m_allDay;
}

void Task::setAllDay(bool allDay)
{
    if (m_allDay == allDay)
        return;

    m_allDay = allDay;
    Q_EMIT allDayChanged(allDay);
}

Task::Reminder Task::reminder() const
{
    return m_reminder;
}

void Task::setReminder(Reminder reminder)
{
    if (m_reminder == reminder)
        return;

    m_reminder = reminder;
    Q_EMIT reminderChanged(reminder);
}

Task::ReminderType Task::reminderType() const
{
    return m_reminderType;
}

void Task::setReminderType(ReminderType reminderType)
{
    if (m_reminderType == reminderType)
        return;

    m_reminderType = reminderType;
    Q_EMIT reminderTypeChanged(reminderType);
}

Task::Repeat Task::repeat() const
{
    return m_repeat;
}

void Task::setRepeat(Repeat repeat)
{
    if (m_repeat == repeat)
        return;

    m_repeat = repeat;
    Q_EMIT repeatChanged(repeat);
}

QString Task::createdDate() const
{
    return m_created.toString("yyyy-MM-dd");
}

QString Task::createdDateTime() const
{
    return m_created.toString(Qt::ISODate);
}

void Task::setCreatedDateTime(const QString &created)
{
    if (m_created.toString(Qt::ISODate) == created)
        return;

    m_created = QDateTime::fromString(created, Qt::ISODate);
    Q_EMIT createdDateTimeChanged(createdDateTime());
    Q_EMIT createdDateChanged(createdDate());
}

QString Task::dueDate() const
{
    return m_due.toString("yyyy-MM-dd");
}

QString Task::dueDateTime() const
{
    return m_due.toString(Qt::ISODate);
}

void Task::setDueDateTime(const QString &due)
{
    if (m_due.toString(Qt::ISODate) == due)
        return;

    m_due = QDateTime::fromString(due, Qt::ISODate);
    Q_EMIT dueDateTimeChanged(dueDateTime());
    Q_EMIT dueDateChanged(dueDate());
}

QString Task::completedDate() const
{
    return m_completed.toString("yyyy-MM-dd");
}

QString Task::completedDateTime() const
{
    return m_completed.toString(Qt::ISODate);
}

void Task::setCompletedDateTime(const QString &completed)
{
    if (m_completed.toString(Qt::ISODate) == completed)
        return;

    m_completed = QDateTime::fromString(completed, Qt::ISODate);
    Q_EMIT completedDateTimeChanged(completedDateTime());
    Q_EMIT completedDateChanged(completedDate());
}
