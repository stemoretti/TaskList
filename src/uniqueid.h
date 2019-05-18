#ifndef UNIQUEID_H
#define UNIQUEID_H

class UniqueID
{
public:
    static int newUID() { return ++m_lastUID; }
    static int lastUID() { return m_lastUID; }
    static void setLastUID(int uid) { m_lastUID = uid; }
private:
    explicit UniqueID() {}
    static int m_lastUID;
};

#endif // UNIQUEID_H
