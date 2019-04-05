#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QTranslator>
#include <QScopedPointer>
#include <QDebug>

#include "appdata.h"
#include "settings.h"

int main(int argc, char *argv[])
{
    QGuiApplication::setAttribute(Qt::AA_EnableHighDpiScaling);
#ifdef QT_DEBUG
    qputenv("QML_DISABLE_DISK_CACHE", "true");
#endif
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;

    QStringList translations({ "en" });
    translations.append(QString(AVAILABLE_TRANSLATIONS).split(' '));
    translations.sort();
    qDebug() << "Available translations:" << translations;
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
    context->setContextProperty("appTranslations", translations);

    engine.load(QUrl(QLatin1String("qrc:/qml/main.qml")));

    return app.exec();
}
