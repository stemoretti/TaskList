#ifndef SORTFILTERMODEL_H
#define SORTFILTERMODEL_H

#include <QSortFilterProxyModel>

class SortFilterModel : public QSortFilterProxyModel
{
    Q_OBJECT

public:
    explicit SortFilterModel(QObject *parent = nullptr);

    virtual bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
    virtual bool lessThan(const QModelIndex &source_left, const QModelIndex &source_right) const override;

    bool hideCompleted() const;

signals:
    void hideCompletedChanged(bool hideCompleted);

public slots:
    void setHideCompleted(bool hideCompleted);

private:
    bool m_hideCompleted;
};

#endif // SORTFILTERMODEL_H
