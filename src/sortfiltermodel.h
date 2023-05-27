#ifndef SORTFILTERMODEL_H
#define SORTFILTERMODEL_H

#include <QSortFilterProxyModel>

#include <functional>

class Task;

using sortFunc = bool(const Task *left, const Task *right);

class SortFilterModel : public QSortFilterProxyModel
{
    Q_OBJECT

public:
    explicit SortFilterModel(QObject *parent = nullptr);

    void setCompareFunction(std::function<sortFunc> func);

protected:
    bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;

private:
    std::function<sortFunc> m_sortFunc;
};

bool alphabeticalInc(const Task *left, const Task *right);
bool alphabeticalDec(const Task *left, const Task *right);
bool createdInc(const Task *left, const Task *right);
bool createdDec(const Task *left, const Task *right);
bool dueInc(const Task *left, const Task *right);
bool dueDec(const Task *left, const Task *right);
bool completedInc(const Task *left, const Task *right);
bool completedDec(const Task *left, const Task *right);

#endif // SORTFILTERMODEL_H
