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
    // From 5.12.3 onwards this environment variable must be set or
    // predictive text won't be disabled (QTBUG-75774)
    // https://code.qt.io/cgit/qt/qtbase.git/plain/dist/changes-5.12.3/?h=v5.12.3
    qputenv("QT_ANDROID_ENABLE_WORKAROUND_TO_DISABLE_PREDICTIVE_TEXT", "true");

    QGuiApplication app(argc, argv);

    if (QFontDatabase::addApplicationFont(":/icons/MaterialIcons-Regular.ttf") == -1)
        qWarning() << "Failed to load font Material";

    QQuickStyle::setStyle("Material");

    QQmlApplicationEngine engine;

    engine.addImageProvider("icon",
                            new IconProvider("Material Icons", ":/icons/codepoints.json"));

    qDebug() << "Available translations:" << System::translations();
    QScopedPointer<QTranslator> translator;
    QCoreApplication::connect(&Settings::instance(), &Settings::languageChanged,
                              [&engine, &translator] (QString language) {
        if (!translator.isNull()) {
            QCoreApplication::removeTranslator(translator.data());
            translator.reset();
        }
        if (language != "en") {
            translator.reset(new QTranslator);
            if (translator->load(QLocale(language), QLatin1String("tasklist"),
                                 QLatin1String("_"), QLatin1String(":/translations")))
                QCoreApplication::installTranslator(translator.data());
        }
        engine.retranslate();
    });

    Settings::instance().readSettingsFile();

    QQmlContext *context = engine.rootContext();
    context->setContextProperty("appData", &AppData::instance());
    context->setContextProperty("appSettings", &Settings::instance());
    context->setContextProperty("appTranslations", System::translations());

    qmlRegisterUncreatableType<Task>("Task", 1, 0, "Task", "test");

    engine.load(QUrl(QLatin1String("qrc:/qml/main.qml")));

    QObject::connect(&app, &QGuiApplication::applicationStateChanged,
                     [=] (Qt::ApplicationState state) {
        if (state == Qt::ApplicationSuspended) {
            AppData::instance().writeListFile();
            Settings::instance().writeSettingsFile();
        }
    });

    return app.exec();
}
