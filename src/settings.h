#ifndef SETTINGS_H
#define SETTINGS_H

#include <QObject>
#include <QColor>
#include <QString>

class Settings : public QObject
{
    Q_OBJECT

    Q_PROPERTY(bool darkTheme READ darkTheme WRITE setDarkTheme NOTIFY darkThemeChanged)
    Q_PROPERTY(QColor primaryColor READ primaryColor WRITE setPrimaryColor NOTIFY primaryColorChanged)
    Q_PROPERTY(QColor accentColor READ accentColor WRITE setAccentColor NOTIFY accentColorChanged)
    Q_PROPERTY(QString language READ language WRITE setLanguage NOTIFY languageChanged)
    Q_PROPERTY(QString country READ country WRITE setCountry NOTIFY countryChanged)

public:
    virtual ~Settings();

    static Settings &instance();

    void readSettingsFile();
    void writeSettingsFile() const;

    //{{{ Properties getters/setters declarations

    bool darkTheme() const;
    void setDarkTheme(bool darkTheme);
    QColor primaryColor() const;
    void setPrimaryColor(const QColor &primaryColor);
    QColor accentColor() const;
    void setAccentColor(const QColor &accentColor);
    QString language() const;
    void setLanguage(const QString &language);
    QString country() const;
    void setCountry(const QString &country);

    //}}} Properties getters/setters declarations

signals:
    //{{{ Properties signals

    void darkThemeChanged(bool darkTheme);
    void primaryColorChanged(QColor primaryColor);
    void accentColorChanged(QColor accentColor);
    void languageChanged(QString language);
    void countryChanged(const QString &country);

    //}}} Properties signals

public slots:

private:
    explicit Settings(QObject *parent = nullptr);
    Q_DISABLE_COPY(Settings)

    QString m_settingsFilePath;

    //{{{ Properties declarations

    bool m_darkTheme;
    QColor m_primaryColor;
    QColor m_accentColor;
    QString m_language;
    QString m_country;

    //}}} Properties declarations
};

#endif // SETTINGS_H
