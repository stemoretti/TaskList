#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QTranslator>
#include <QScopedPointer>
#include <QUrl>
#include <QDebug>

#include <BaseUI/core.h>

#include "appdata.h"
#include "settings.h"
#include "system.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setApplicationName("TaskList");

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine *engine = new QQmlApplicationEngine();

    System::init(engine);
    Settings::init(engine);
    AppData::init(engine);

    BaseUI::init(engine);

    qDebug() << "Available translations:" << System::translations();
    QScopedPointer<QTranslator> translator;
    QObject::connect(Settings::instance, &Settings::languageChanged,
                     [engine, &translator](QString language) {
        if (!translator.isNull())
            QCoreApplication::removeTranslator(translator.data());
        translator.reset(new QTranslator);
        if (translator->load(QLocale(language), "tasklist", "_", ":/i18n"))
            QCoreApplication::installTranslator(translator.data());
        engine->retranslate();
    });

    Settings::instance->readSettingsFile();
    AppData::instance->readListFile();

    QUrl url("qrc:/qml/main.qml");
    QObject::connect(engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine->load(url);

    QObject::connect(&app, &QGuiApplication::applicationStateChanged,
                     [](Qt::ApplicationState state) {
        if (state == Qt::ApplicationSuspended) {
            AppData::instance->writeListFile();
            Settings::instance->writeSettingsFile();
        }
    });

    int ret = app.exec();

    delete engine;

    return ret;
}
