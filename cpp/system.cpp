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

QStringList System::translations()
{
    QStringList translations({ "en" });
    translations.append(QString(AVAILABLE_TRANSLATIONS).split(' '));
    translations.sort();
    return translations;
}
