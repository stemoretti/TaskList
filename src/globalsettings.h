#ifndef GLOBALSETTINGS_H
#define GLOBALSETTINGS_H

#include <QObject>
#include <QColor>
#include <QString>
#include <QTranslator>

#include <QtQml/qqmlregistration.h>

class QQmlEngine;
class QJSEngine;

class GlobalSettings : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

    Q_PROPERTY(QString theme READ theme WRITE setTheme NOTIFY themeChanged)
    Q_PROPERTY(QColor primaryColor READ primaryColor WRITE setPrimaryColor NOTIFY primaryColorChanged)
    Q_PROPERTY(QColor accentColor READ accentColor WRITE setAccentColor NOTIFY accentColorChanged)
    Q_PROPERTY(bool toolBarPrimary READ toolBarPrimary WRITE setToolBarPrimary NOTIFY toolBarPrimaryChanged)
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(QString country READ country WRITE setCountry NOTIFY countryChanged)
    Q_PROPERTY(bool strikeCompleted READ strikeCompleted WRITE setStrikeCompleted NOTIFY strikeCompletedChanged)
    Q_PROPERTY(bool timeAMPM READ timeAMPM WRITE setTimeAMPM NOTIFY timeAMPMChanged)
    Q_PROPERTY(bool timeTumbler READ timeTumbler WRITE setTimeTumbler NOTIFY timeTumblerChanged)

public:
    ~GlobalSettings();

    inline static GlobalSettings *instance;
    static void init(QObject *parent = nullptr) { instance = new GlobalSettings(parent); }
    static GlobalSettings *create(QQmlEngine *, QJSEngine *) { return instance; }

    Q_INVOKABLE void loadSettings();
    Q_INVOKABLE void saveSettings() const;

    QString theme() const;
    void setTheme(const QString &theme);

    QColor primaryColor() const;
    void setPrimaryColor(const QColor &primaryColor);

    QColor accentColor() const;
    void setAccentColor(const QColor &accentColor);

    bool toolBarPrimary() const;
    void setToolBarPrimary(bool toolBarPrimary);

    QString language() const;
    void setLanguage(const QString &language);

    QString country() const;
    void setCountry(const QString &country);

    bool strikeCompleted() const;
    void setStrikeCompleted(bool strikeCompleted);

    bool timeAMPM() const;
    void setTimeAMPM(bool timeAMPM);

    bool timeTumbler() const;
    void setTimeTumbler(bool timeTumbler);

Q_SIGNALS:
    void themeChanged(const QString &theme);
    void primaryColorChanged(const QColor &primaryColor);
    void accentColorChanged(const QColor &accentColor);
    void toolBarPrimaryChanged(bool toolBarPrimary);
    void languageChanged(const QString &language);
    void countryChanged(const QString &country);
    void strikeCompletedChanged(bool strikeCompleted);
    void timeAMPMChanged(bool timeAMPM);
    void timeTumblerChanged(bool timeTumbler);

private:
    explicit GlobalSettings(QObject *parent = nullptr);
    Q_DISABLE_COPY_MOVE(GlobalSettings)

    void updateTranslator(const QString &language);

    QTranslator m_translator;
    QString m_settingsFilePath;

    QString m_theme;
    QColor m_primaryColor;
    QColor m_accentColor;
    bool m_toolBarPrimary;
    QString m_language;
    QString m_country;
    bool m_strikeCompleted;
    bool m_timeAMPM;
    bool m_timeTumbler;
};

#endif
