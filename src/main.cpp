#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QUrl>

#include <BaseUI/core.h>

#include "appdata.h"
#include "globalsettings.h"
#include "system.h"

int main(int argc, char *argv[])
{
    QCoreApplication::setApplicationName("TaskList");

    QGuiApplication app(argc, argv);

    QQmlApplicationEngine *engine = new QQmlApplicationEngine();

    System::init(engine);
    GlobalSettings::init(engine);
    AppData::init(engine);

    BaseUI::init(engine);

    QUrl url("qrc:/qml/main.qml");
    QObject::connect(engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl)
            QCoreApplication::exit(-1);
    }, Qt::QueuedConnection);
    engine->load(url);

    int ret = app.exec();

    delete engine;

    return ret;
}
