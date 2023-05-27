#include "appdata.h"

#include <QDir>
#include <QJsonObject>
#include <QJsonDocument>
#include <QJsonArray>
#include <QQmlEngine>
#include <QUrl>

#include "system.h"
#include "uniqueid.h"

AppData::AppData(QObject *parent)
    : QObject(parent)
    , m_lists(new QQmlObjectListModel<List>(this))
    , m_listFilePath(System::dataPath() + "/lists.json")
    , m_currentList(nullptr)
    , m_drawerEnabled(true)
{
    QQmlEngine::setObjectOwnership(this, QQmlEngine::CppOwnership);
}

AppData::~AppData()
{
    writeListFile();
}

void AppData::readListFile(const QString &path)
{
#ifdef Q_OS_ANDROID
    QFile readFile(path.isEmpty() ? m_listFilePath : path);
#else
    QFile readFile(path.isEmpty() ? m_listFilePath : QUrl(path).toLocalFile());
#endif

    qDebug() << "Read the list database" << readFile.fileName();

    if (!readFile.exists()) {
        qWarning() << "List cache doesn't exist:" << path;
        return;
    }
    if (!readFile.open(QIODevice::ReadOnly)) {
        qWarning() << "Cannot open file:" << m_listFilePath;
        return;
    }
    auto jdoc = QJsonDocument::fromJson(readFile.readAll());
    if (!jdoc.isObject()) {
        qWarning() << "Cannot read JSON file:" << m_listFilePath;
        qWarning() << readFile.errorString();
        return;
    }
    readFile.close();
    QJsonObject jobj = jdoc.object();
    for (const auto o : jobj["lists"].toArray())
        m_lists->append(List::fromJson(o.toObject()));
    QJsonValue curList = jobj["current"];
    if (!curList.isNull() && !curList.toString().isEmpty())
        selectList(curList.toString());
    UniqueID::setLastUID(jobj["lastUID"].toInt());

    qDebug() << m_lists->count() << "lists loaded";
    qDebug() << "List database read";
}

void AppData::writeListFile(const QString &path) const
{
    qDebug() << "Write the list file";

    QFile writeFile(path.isEmpty() ? m_listFilePath : path);

    if (!writeFile.open(QIODevice::WriteOnly)) {
        qWarning() << "Cannot open file:" << writeFile.fileName();
        return;
    }
    QJsonObject jobj;
    QJsonArray jarrLists;
    for (const auto &i : m_lists->toList())
        jarrLists.append(i->toJson());
    jobj["lists"] = jarrLists;
    jobj["current"] = currentList() ? currentList()->name() : "";
    jobj["lastUID"] = UniqueID::lastUID();
    writeFile.write(QJsonDocument(jobj).toJson());
    writeFile.close();

    qDebug() << "List saved";
}

int AppData::findList(const QString &name) const
{
    for (int i = 0; i < m_lists->count(); i++) {
        if (m_lists->at(i)->name() == name)
            return i;
    }
    return -1;
}

bool AppData::addList(const QString &name) const
{
    if (findList(name) >= 0)
        return false;
    m_lists->append(new List(name));

    return true;
}

void AppData::selectList(const QString &name)
{
    int i = findList(name);
    if (i >= 0)
        setCurrentList(m_lists->at(i));
}

void AppData::removeList(const QString &name)
{
    int i = findList(name);
    if (i >= 0)
        removeList(i);
}

void AppData::removeList(int index)
{
    if (index >= 0 && index < m_lists->count()) {
        if (m_lists->indexOf(currentList()) == index) {
            m_lists->remove(index);
            if (index < m_lists->count())
                setCurrentList(m_lists->at(index));
            else if (m_lists->count())
                setCurrentList(m_lists->at(m_lists->count() - 1));
            else
                setCurrentList(nullptr);
        } else {
            m_lists->remove(index);
        }
    }
}

List *AppData::currentList() const
{
    return m_currentList;
}

void AppData::setCurrentList(List *currentList)
{
    if (m_currentList == currentList)
        return;

    m_currentList = currentList;
    Q_EMIT currentListChanged(m_currentList);
}
