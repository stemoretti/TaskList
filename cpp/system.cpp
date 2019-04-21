#include "system.h"

#include <QStandardPaths>
#include <QLocale>

System::System(QObject *parent) : QObject(parent)
{
}

QString System::dataRoot()
{
    return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
}

QString System::systemLanguage()
{
    return QLocale().name().left(2);
}

QString System::systemRegion()
{
    return QLocale().name();
}
