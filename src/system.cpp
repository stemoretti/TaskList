#include "system.h"

#include <QStandardPaths>
#include <QLocale>
#include <QQmlEngine>

System::System(QObject *parent)
    : QObject(parent)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

System *System::instance()
{
    static System instance;

    return &instance;
}

QObject *System::singletonProvider(QQmlEngine *qmlEngine, QJSEngine *jsEngine)
{
    (void)qmlEngine;
    (void)jsEngine;

    return instance();
}

QString System::dataPath()
{
    QStringList dataLocations = QStandardPaths::standardLocations(QStandardPaths::AppDataLocation);
#ifdef Q_OS_ANDROID
    if (dataLocations.size() > 1)
        return dataLocations[1];
#endif
    return dataLocations[0];
}

QString System::language()
{
    return QLocale().name().left(2);
}

QString System::locale()
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
