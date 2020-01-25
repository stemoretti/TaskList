#ifndef TASK_H
#define TASK_H

#include <QObject>
#include <QJsonObject>
#include <QDateTime>

class Task : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int id READ id NOTIFY idChanged)
    Q_PROPERTY(QString name READ name NOTIFY nameChanged)
    Q_PROPERTY(bool checked READ checked WRITE setChecked NOTIFY checkedChanged)
    Q_PROPERTY(QDateTime created READ created NOTIFY createdChanged)
    Q_PROPERTY(QString notes READ notes WRITE setNotes NOTIFY notesChanged)
    Q_PROPERTY(QDate dueDate READ dueDate WRITE setDueDate NOTIFY dueDateChanged)
    Q_PROPERTY(QTime dueTime READ dueTime WRITE setDueTime NOTIFY dueTimeChanged)
    Q_PROPERTY(AlarmMode alarm READ alarm WRITE setAlarm NOTIFY alarmChanged)
    Q_PROPERTY(QDateTime completed READ completed WRITE setCompleted NOTIFY completedChanged)

public:
    enum AlarmMode {
        NoAlarm,
        Notification,
        Alarm
    };
    Q_ENUM(AlarmMode)

    explicit Task(const QString &name = QString(), int id = 0, QObject *parent = nullptr);

    static Task *fromJson(const QJsonObject &json);
    QJsonObject toJson() const;

    //{{{ Properties getters/setters declarations

    int id() const;
    void setId(int id);

    QString name() const;
    void setName(const QString &name);

    bool checked() const;
    void setChecked(bool checked);

    QDateTime created() const;
    void setCreated(const QDateTime &created);

    QString notes() const;
    void setNotes(const QString &notes);

    QDate dueDate() const;
    void setDueDate(const QDate &dueDate);

    QTime dueTime() const;
    void setDueTime(const QTime &dueTime);

    AlarmMode alarm() const;
    void setAlarm(AlarmMode alarm);

    QDateTime completed() const;
    void setCompleted(const QDateTime &completed);

    //}}} Properties getters/setters declarations

signals:
    //{{{ Properties signals

    void idChanged(int id);
    void nameChanged(QString name);
    void checkedChanged(bool checked);
    void createdChanged(QDateTime created);
    void notesChanged(const QString &notes);
    void dueDateChanged(const QDate &dueDate);
    void dueTimeChanged(const QTime &dueTime);
    void alarmChanged(AlarmMode alarm);
    void completedChanged(const QDateTime &completed);

    //}}} Properties signals

private:
    //{{{ Properties declarations

    int m_id;
    QString m_name;
    bool m_checked;
    QDateTime m_created;
    QString m_notes;
    QDate m_dueDate;
    QTime m_dueTime;
    AlarmMode m_alarm;
    QDateTime m_completed;

    //}}} Properties declarations
};

#endif // TASK_H
