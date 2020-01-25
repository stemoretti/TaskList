#include "sortfiltermodel.h"

#include "QQmlObjectListModel.h"
#include "task.h"

SortFilterModel::SortFilterModel(QObject *parent)
    : QSortFilterProxyModel(parent)
    , m_hideCompleted(false)
{
    sort(0);
}

bool SortFilterModel::filterAcceptsRow(int sourceRow,
                                       const QModelIndex &sourceParent) const
{
    Q_UNUSED(sourceParent)
    auto m = static_cast<QQmlObjectListModel<Task>*>(sourceModel());
    if (hideCompleted())
        return !m->at(sourceRow)->checked();
    return true;
}

bool SortFilterModel::lessThan(const QModelIndex &source_left,
                               const QModelIndex &source_right) const
{
    auto m = static_cast<QQmlObjectListModel<Task>*>(sourceModel());
    Task *left = m->at(source_left.row());
    Task *right = m->at(source_right.row());
    return QDateTime(left->dueDate(), left->dueTime())
            < QDateTime(right->dueDate(), right->dueTime());
}

bool SortFilterModel::hideCompleted() const
{
    return m_hideCompleted;
}

void SortFilterModel::setHideCompleted(bool hideCompleted)
{
    if (hideCompleted == m_hideCompleted)
        return;

    m_hideCompleted = hideCompleted;
    emit hideCompletedChanged(m_hideCompleted);
    invalidate();
}
