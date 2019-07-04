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
    Q_PROPERTY(QDateTime due READ due WRITE setDue NOTIFY dueChanged)
    Q_PROPERTY(AlarmMode alarm READ alarm WRITE setAlarm NOTIFY alarmChanged)
    Q_PROPERTY(QDateTime completed READ completed WRITE setCompleted NOTIFY completedChanged)

public:
    explicit Task(const QString &name = QString(), int id = 0, QObject *parent = nullptr);

    enum AlarmMode { NoAlarm, Notification, Alarm };
    Q_ENUM(AlarmMode)

    static Task *fromJson(const QJsonObject &json);
    QJsonObject toJson() const;

    //{{{ Properties getters declarations

    int id() const;
    QString name() const;
    bool checked() const;
    QDateTime created() const;
    QString notes() const;
    QDateTime due() const;
    AlarmMode alarm() const;
    QDateTime completed() const;

    //}}} Properties getters declarations

signals:
    //{{{ Properties signals

    void idChanged(int id);
    void nameChanged(QString name);
    void checkedChanged(bool checked);
    void createdChanged(QDateTime created);
    void notesChanged(const QString &notes);
    void dueChanged(const QDateTime &due);
    void alarmChanged(AlarmMode alarm);
    void completedChanged(const QDateTime &completed);

    //}}} Properties signals

public slots:
    //{{{ Properties setters declarations

    void setId(int id);
    void setName(const QString &name);
    void setChecked(bool checked);
    void setCreated(const QDateTime &created);
    void setNotes(const QString &notes);
    void setDue(const QDateTime &due);
    void setAlarm(AlarmMode alarm);
    void setCompleted(const QDateTime &completed);

    //}}} Properties setters declarations

private:
    //{{{ Properties declarations

    int m_id;
    QString m_name;
    bool m_checked;
    QDateTime m_created;
    QString m_notes;
    QDateTime m_due;
    AlarmMode m_alarm;
    QDateTime m_completed;

    //}}} Properties declarations
};

#endif // TASK_H
