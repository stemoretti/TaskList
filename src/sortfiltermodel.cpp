#include "sortfiltermodel.h"

#include <QQmlObjectListModel.h>

#include "task.h"

static bool dateTimeInc(const QString &left, const QString &right)
{
    if (left.isNull())
        return false;
    if (right.isNull())
        return true;
    return QDateTime::fromString(left, Qt::ISODate) < QDateTime::fromString(right, Qt::ISODate);
}

static bool dateTimeDec(const QString &left, const QString &right)
{
    if (left.isNull())
        return false;
    if (right.isNull())
        return true;
    return QDateTime::fromString(left, Qt::ISODate) > QDateTime::fromString(right, Qt::ISODate);
}

SortFilterModel::SortFilterModel(QObject *parent)
    : QSortFilterProxyModel(parent)
    , m_sortFunc(dueDec)
{
    sort(0);
}

bool SortFilterModel::lessThan(const QModelIndex &source_left,
                               const QModelIndex &source_right) const
{
    auto tasks = static_cast<QQmlObjectListModel<Task> *>(sourceModel());
    return m_sortFunc(tasks->at(source_left.row()), tasks->at(source_right.row()));
}

void SortFilterModel::setCompareFunction(std::function<sortFunc> func)
{
    m_sortFunc = func;
    invalidate();
}

bool alphabeticalInc(const Task *left, const Task *right)
{
    return left->name().compare(right->name(), Qt::CaseInsensitive) < 0;
}

bool alphabeticalDec(const Task *left, const Task *right)
{
    return left->name().compare(right->name(), Qt::CaseInsensitive) > 0;
}

bool createdInc(const Task *left, const Task *right)
{
    return dateTimeInc(left->createdDateTime(), right->createdDateTime());
}

bool createdDec(const Task *left, const Task *right)
{
    return dateTimeDec(left->createdDateTime(), right->createdDateTime());
}

bool dueInc(const Task *left, const Task *right)
{
    return dateTimeInc(left->dueDateTime(), right->dueDateTime());
}

bool dueDec(const Task *left, const Task *right)
{
    return dateTimeDec(left->dueDateTime(), right->dueDateTime());
}

bool completedInc(const Task *left, const Task *right)
{
    return dateTimeInc(left->completedDateTime(), right->completedDateTime());
}

bool completedDec(const Task *left, const Task *right)
{
    return dateTimeDec(left->completedDateTime(), right->completedDateTime());
}
