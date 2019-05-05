#ifndef SYSTEM_H
#define SYSTEM_H

#include <QObject>

class System : public QObject
{
    Q_OBJECT

public:
    static QString dataRoot();
    static QString systemLanguage();
    static QString systemRegion();
    static QStringList translations();

private:
    explicit System(QObject *parent = nullptr);
};

#endif // SYSTEM_H
