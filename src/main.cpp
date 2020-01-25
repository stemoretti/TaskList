#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickStyle>
#include <QTranslator>
#include <QScopedPointer>
#include <QFontDatabase>
#include <QDebug>

#include "appdata.h"
#include "iconprovider.h"
#include "settings.h"
#include "system.h"
#include "task.h"

int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#ifdef QT_DEBUG
    qputenv("QML_DISABLE_DISK_CACHE", "true");
#endif
    QGuiApplication app(argc, argv);

    if (QFontDatabase::addApplicationFont(":/icons/MaterialIcons-Regular.ttf") == -1)
        qWarning() << "Failed to load font Material";

    QQuickStyle::setStyle("Material");

    QQmlApplicationEngine engine;

    engine.addImageProvider("icon", new IconProvider("Material Icons", ":/icons/codepoints.json"));

    qDebug() << "Available translations:" << System::translations();
    QScopedPointer<QTranslator> translator;
    QObject::connect(Settings::instance(), &Settings::languageChanged,
                     [&engine, &translator](QString language) {
        if (!translator.isNull()) {
            QCoreApplication::removeTranslator(translator.data());
            translator.reset();
        }
        if (language != "en") {
            translator.reset(new QTranslator);
            if (translator->load(QLocale(language), "tasklist", "_", ":/translations"))
                QCoreApplication::installTranslator(translator.data());
        }
        engine.retranslate();
    });

    Settings::instance()->readSettingsFile();

    qmlRegisterSingletonType<AppData>("AppData", 1, 0, "AppData", AppData::singletonProvider);
    qmlRegisterSingletonType<Settings>("Settings", 1, 0, "Settings", Settings::singletonProvider);
    qmlRegisterSingletonType<System>("System", 1, 0, "System", System::singletonProvider);

    qmlRegisterUncreatableType<Task>("Task", 1, 0, "Task", "test");

    engine.load(QUrl("qrc:/qml/main.qml"));

    QObject::connect(&app, &QGuiApplication::applicationStateChanged,
                     [=](Qt::ApplicationState state) {
        if (state == Qt::ApplicationSuspended) {
            AppData::instance()->writeListFile();
            Settings::instance()->writeSettingsFile();
        }
    });

    return app.exec();
}
