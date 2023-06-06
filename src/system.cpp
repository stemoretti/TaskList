#include "system.h"

#include <QStandardPaths>
#include <QLocale>
#include <QQmlEngine>
#include <QDir>

#ifdef Q_OS_ANDROID
#include <QCoreApplication>
#include <QJniObject>

#include "settings.h"
#endif

System::System(QObject *parent)
    : QObject(parent)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
    if (!checkDirs())
        qFatal("App won't work - cannot create data directory.");
}

bool System::checkDirs() const
{
    QDir myDir;
    QString path = System::dataPath();

    if (!myDir.exists(path)) {
        if (!myDir.mkpath(path)) {
            qWarning() << "Cannot create" << path;
            return false;
        }
        qDebug() << "Created directory" << path;
    }

    return true;
}

QString System::dataPath()
{
    return QStandardPaths::writableLocation(QStandardPaths::AppDataLocation);
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
    QDir translationsDir(":/i18n");
    QStringList languages;

    if (translationsDir.exists()) {
        QStringList translations = translationsDir.entryList({ "*.qm" });
        translations.replaceInStrings("tasklist_", "");
        translations.replaceInStrings(".qm", "");
        languages.append(translations);
        languages.sort();
    }

    return languages;
}

#ifdef Q_OS_ANDROID
extern "C" JNIEXPORT void JNICALL
Java_com_github_stemoretti_tasklist_MainActivity_sendResult(JNIEnv *env,
                                                            jobject obj,
                                                            jstring text)
{
    Q_UNUSED(env)
    Q_UNUSED(obj)
    auto result = QJniObject(text).toString();
    if (!result.isEmpty()) {
        result[0] = result[0].toUpper();
        Q_EMIT System::instance->speechRecognized(result);
    }
}
#endif

void System::startSpeechRecognizer() const
{
#ifdef Q_OS_ANDROID
    auto javaString = QJniObject::fromString(Settings::instance->country());
    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    activity.callMethod<void>("getSpeechInput", "(Ljava/lang/String;)V",
                              javaString.object());
#endif
}

void System::setAlarm(int id, long long time, const QString &task) const
{
#ifdef Q_OS_ANDROID
    auto javaString = QJniObject::fromString(task);
    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    activity.callMethod<void>("setAlarm", "(IJLjava/lang/String;)V",
                              id, time, javaString.object());
#endif
}

void System::cancelAlarm(int id) const
{
#ifdef Q_OS_ANDROID
    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    activity.callMethod<void>("cancelAlarm", "(I)V", id);
#endif
}

void System::updateStatusBarColor(bool darkTheme) const
{
#ifdef Q_OS_ANDROID
    bool toolBarPrimary = Settings::instance->toolBarPrimary();
    QColor navbg = darkTheme ? "#1C1B1F" : "#FFFBFE";
    QColor bg = toolBarPrimary ? Settings::instance->primaryColor().darker(140) : navbg;
    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    activity.callMethod<void>("setStatusBarColor", "(IIZZ)V", bg.rgba(), navbg.rgba(),
                              toolBarPrimary, darkTheme);
#endif
}

void System::checkPermissions() const
{
#ifdef Q_OS_ANDROID
    QJniObject activity = QNativeInterface::QAndroidApplication::context();
    activity.callMethod<void>("checkPermissions", "()V");
#endif
}
