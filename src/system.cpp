#include "system.h"

#include <QStandardPaths>
#include <QLocale>

QString System::dataPath()
{
    return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
}

QString System::language()
{
    return QLocale().name().left(2);
}

QString System::region()
{
    return QLocale().name();
}

QStringList System::translations()
{
    QStringList translations({ "en" });
    translations.append(QString(AVAILABLE_TRANSLATIONS).split(' '));
    translations.sort();
    return translations;
}
