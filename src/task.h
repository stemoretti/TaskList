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
    Q_PROPERTY(QDateTime completed READ completed WRITE setCompleted NOTIFY completedChanged)

public:
    explicit Task(const QString &name = QString(), int id = 0, QObject *parent = nullptr);

    static Task *fromJson(const QJsonObject &json);
    QJsonObject toJson() const;

    //{{{ Properties getters declarations

    int id() const;
    QString name() const;
    bool checked() const;
    QDateTime created() const;
    QString notes() const;
    QDate dueDate() const;
    QTime dueTime() const;
    QDateTime completed() const;

    //}}} Properties getters declarations

signals:
    //{{{ Properties signals

    void idChanged(int id);
    void nameChanged(QString name);
    void checkedChanged(bool checked);
    void createdChanged(QDateTime created);
    void notesChanged(const QString &notes);
    void dueDateChanged(const QDate &dueDate);
    void dueTimeChanged(const QTime &dueTime);
    void completedChanged(const QDateTime &completed);

    //}}} Properties signals

public slots:
    //{{{ Properties setters declarations

    void setId(int id);
    void setName(const QString &name);
    void setChecked(bool checked);
    void setCreated(const QDateTime &created);
    void setNotes(const QString &notes);
    void setDueDate(const QDate &dueDate);
    void setDueTime(const QTime &dueTime);
    void setCompleted(const QDateTime &completed);

    //}}} Properties setters declarations

private:
    //{{{ Properties declarations

    int m_id;
    QString m_name;
    bool m_checked;
    QDateTime m_created;
    QString m_notes;
    QDate m_dueDate;
    QTime m_dueTime;
    QDateTime m_completed;

    //}}} Properties declarations
};

#endif // TASK_H
