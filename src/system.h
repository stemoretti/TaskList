#ifndef SYSTEM_H
#define SYSTEM_H

#include <QString>

class System
{
public:
    static QString dataPath();
    static QString language();
    static QString locale();
    static QStringList translations();

private:
    explicit System() {}
};

#endif // SYSTEM_H
