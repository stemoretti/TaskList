#include "settings.h"

#include <QDebug>
#include <QFile>
#include <QJsonDocument>
#include <QJsonObject>
#include <QStringList>
#include <QQmlEngine>

#include "system.h"

Settings::Settings(QObject *parent)
    : QObject(parent)
    , m_settingsFilePath(System::dataPath() + "/settings.json")
    , m_theme("Sytem")
    , m_primaryColor("#607D8B") // Material.BlueGrey
    , m_accentColor("#FF9800") // Material.Orange
    , m_toolBarPrimary(true)
    , m_language("")
    , m_country("en_US")
    , m_strikeCompleted(false)
    , m_timeAMPM(false)
    , m_timeTumbler(false)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

Settings::~Settings()
{
    writeSettingsFile();
}

void Settings::readSettingsFile()
{
    qDebug() << "Read the settings file";

    QFile readFile(m_settingsFilePath);

    if (!readFile.exists()) {
        qWarning() << "Cannot find the settings file:" << m_settingsFilePath;
        qDebug() << "Using default settings values";
        setCountry(System::locale());
        if (System::translations().contains(System::language()))
            setLanguage(System::language());
        else
            setLanguage("en");
        return;
    }
    if (!readFile.open(QIODevice::ReadOnly)) {
        qWarning() << "Cannot open file:" << m_settingsFilePath;
        return;
    }
    auto jdoc = QJsonDocument::fromJson(readFile.readAll());
    readFile.close();
    if (!jdoc.isObject()) {
        qWarning() << "Cannot read JSON file:" << m_settingsFilePath;
        return;
    }
    QJsonObject jobj = jdoc.object();
    setTheme(jobj["theme"].toString());
    setPrimaryColor(jobj["primaryColor"].toString());
    setAccentColor(jobj["accentColor"].toString());
    setToolBarPrimary(jobj["toolBarPrimary"].toBool());
    setLanguage(jobj["language"].toString());
    setCountry(jobj["country"].toString());
    setStrikeCompleted(jobj["strikeCompleted"].toBool());
    setTimeAMPM(jobj["timeAMPM"].toBool());
    setTimeTumbler(jobj["timeTumbler"].toBool());

    qDebug() << "Settings file read";
}

void Settings::writeSettingsFile() const
{
    qDebug() << "Write the settings file";

    QFile writeFile(m_settingsFilePath);

    if (!writeFile.open(QIODevice::WriteOnly)) {
        qWarning() << "Cannot open file for writing:" << m_settingsFilePath;
        return;
    }
    QJsonObject jobj;
    jobj["theme"] = m_theme;
    jobj["primaryColor"] = m_primaryColor.name(QColor::HexRgb);
    jobj["accentColor"] = m_accentColor.name(QColor::HexRgb);
    jobj["toolBarPrimary"] = m_toolBarPrimary;
    jobj["language"] = m_language;
    jobj["country"] = m_country;
    jobj["strikeCompleted"] = m_strikeCompleted;
    jobj["timeAMPM"] = m_timeAMPM;
    jobj["timeTumbler"] = m_timeTumbler;
    writeFile.write(QJsonDocument(jobj).toJson());
    writeFile.close();

    qDebug() << "Settings file saved";
}

QString Settings::theme() const
{
    return m_theme;
}

void Settings::setTheme(const QString &theme)
{
    if (m_theme == theme)
        return;

    m_theme = theme;
    Q_EMIT themeChanged(theme);
}

QColor Settings::primaryColor() const
{
    return m_primaryColor;
}

void Settings::setPrimaryColor(const QColor &primaryColor)
{
    if (m_primaryColor == primaryColor)
        return;

    m_primaryColor = primaryColor;
    Q_EMIT primaryColorChanged(m_primaryColor);
}

QColor Settings::accentColor() const
{
    return m_accentColor;
}

void Settings::setAccentColor(const QColor &accentColor)
{
    if (m_accentColor == accentColor)
        return;

    m_accentColor = accentColor;
    Q_EMIT accentColorChanged(m_accentColor);
}

bool Settings::toolBarPrimary() const
{
    return m_toolBarPrimary;
}

void Settings::setToolBarPrimary(bool toolBarPrimary)
{
    if (m_toolBarPrimary == toolBarPrimary)
        return;

    m_toolBarPrimary = toolBarPrimary;
    Q_EMIT toolBarPrimaryChanged(toolBarPrimary);
}

QString Settings::language() const
{
    return m_language;
}

void Settings::setLanguage(const QString &language)
{
    if (m_language == language)
        return;

    m_language = language;
    Q_EMIT languageChanged(m_language);
}

QString Settings::country() const
{
    return m_country;
}

void Settings::setCountry(const QString &country)
{
    if (m_country == country)
        return;

    m_country = country;
    Q_EMIT countryChanged(m_country);
}

bool Settings::strikeCompleted() const
{
    return m_strikeCompleted;
}

void Settings::setStrikeCompleted(bool strikeCompleted)
{
    if (m_strikeCompleted == strikeCompleted)
        return;

    m_strikeCompleted = strikeCompleted;
    Q_EMIT strikeCompletedChanged(strikeCompleted);
}

bool Settings::timeAMPM() const
{
    return m_timeAMPM;
}

void Settings::setTimeAMPM(bool timeAMPM)
{
    if (m_timeAMPM == timeAMPM)
        return;

    m_timeAMPM = timeAMPM;
    Q_EMIT timeAMPMChanged(timeAMPM);
}

bool Settings::timeTumbler() const
{
    return m_timeTumbler;
}

void Settings::setTimeTumbler(bool timeTumbler)
{
    if (m_timeTumbler == timeTumbler)
        return;

    m_timeTumbler = timeTumbler;
    Q_EMIT timeTumblerChanged(timeTumbler);
}
