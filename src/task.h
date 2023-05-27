#ifndef TASK_H
#define TASK_H

#include <QObject>
#include <QJsonObject>
#include <QDateTime>

#include <QtQml/qqmlregistration.h>

class Task : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("")

    Q_PROPERTY(int id READ id NOTIFY idChanged)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(bool completed READ completed WRITE setCompleted NOTIFY completedChanged)
    Q_PROPERTY(QString notes READ notes WRITE setNotes NOTIFY notesChanged)

    Q_PROPERTY(bool allDay READ allDay WRITE setAllDay NOTIFY allDayChanged)
    Q_PROPERTY(Reminder reminder READ reminder WRITE setReminder NOTIFY reminderChanged)
    Q_PROPERTY(ReminderType reminderType READ reminderType WRITE setReminderType NOTIFY reminderTypeChanged)
    Q_PROPERTY(Repeat repeat READ repeat WRITE setRepeat NOTIFY repeatChanged)

    Q_PROPERTY(QString createdDate READ createdDate NOTIFY createdDateChanged)
    Q_PROPERTY(QString createdDateTime READ createdDateTime NOTIFY createdDateTimeChanged)
    Q_PROPERTY(QString dueDate READ dueDate NOTIFY dueDateChanged)
    Q_PROPERTY(QString dueDateTime READ dueDateTime WRITE setDueDateTime NOTIFY dueDateTimeChanged)
    Q_PROPERTY(QString completedDate READ completedDate NOTIFY completedDateChanged)
    Q_PROPERTY(QString completedDateTime READ completedDateTime NOTIFY completedDateTimeChanged)

public:
    enum class Reminder {
        Off,
        WhenDue,
        InAdvance
    };
    Q_ENUM(Reminder)

    enum class ReminderType {
        Notification,
        Alarm
    };
    Q_ENUM(ReminderType)

    enum class Repeat {
        Off,
        Daily,
        Weekly,
        Monthly,
        Yearly,
        DayOfWeek,
        Advanced
    };
    Q_ENUM(Repeat)

    explicit Task(const QString &name = QString(), int id = 0, QObject *parent = nullptr);

    static Task *fromJson(const QJsonObject &json);
    QJsonObject toJson() const;

    Q_INVOKABLE static long long dateToMillisec(const QString &date) {
        return QDateTime::fromString(date, Qt::ISODate).toMSecsSinceEpoch();
    }

    int id() const;
    void setId(int id);

    QString name() const;
    void setName(const QString &name);

    bool completed() const;
    void setCompleted(bool completed);

    QString notes() const;
    void setNotes(const QString &notes);

    bool allDay() const;
    void setAllDay(bool allDay);

    Reminder reminder() const;
    void setReminder(Reminder reminder);

    ReminderType reminderType() const;
    void setReminderType(ReminderType reminderType);

    Repeat repeat() const;
    void setRepeat(Repeat repeat);

    QString createdDate() const;
    QString createdDateTime() const;
    void setCreatedDateTime(const QString &created);

    QString dueDate() const;
    QString dueDateTime() const;
    void setDueDateTime(const QString &due);

    QString completedDate() const;
    QString completedDateTime() const;
    void setCompletedDateTime(const QString &completed);

Q_SIGNALS:
    void idChanged(int id);
    void nameChanged(const QString &name);
    void completedChanged(bool completed);
    void notesChanged(const QString &notes);
    void allDayChanged(bool allDay);
    void reminderChanged(Reminder reminder);
    void reminderTypeChanged(ReminderType reminderType);
    void repeatChanged(Repeat repeat);
    void createdDateChanged(const QString &created);
    void createdDateTimeChanged(const QString &created);
    void dueDateChanged(const QString &due);
    void dueDateTimeChanged(const QString &due);
    void completedDateChanged(const QString &completed);
    void completedDateTimeChanged(const QString &completed);

private:
    int m_id;
    QString m_name;
    QString m_notes;
    bool m_allDay;
    Reminder m_reminder;
    ReminderType m_reminderType;
    Repeat m_repeat;
    QDateTime m_created;
    QDateTime m_due;
    QDateTime m_completed;
};

#endif // TASK_H
