#include "TaskItem.h"
#include <QMetaObject>
#include <QTimer>

TaskItem::TaskItem(const QString &description, int priority, QDateTime dueDate, QObject *parent)
    : QObject(parent)
    , m_description(description)
    , m_priority(priority)
    , m_dueDate(dueDate)
    , m_pastDueTimer(new QTimer(this))
{
    connect(m_pastDueTimer, &QTimer::timeout, this, &TaskItem::updatePastDue);
    updatePastDueTimer();
}

void TaskItem::setDescription(const QString &description)
{
    if (m_description == description)
        return;

    m_description = description;
    emit descriptionChanged();
}

void TaskItem::setPriority(int priority)
{
    if (m_priority == priority)
        return;

    m_priority = priority;
    emit priorityChanged();
}

void TaskItem::setDueDate(const QDateTime &newDueDate)
{
    if (m_dueDate == newDueDate)
        return;

    m_dueDate = newDueDate;
    emit dueDateChanged();
    updatePastDue();
}

void TaskItem::setDone(bool done)
{
    m_done = done;
    emit doneChanged();
}

QHash<int, QByteArray> TaskItem::roleNames()
{
    static const QHash<int, QByteArray> roleNames = []() {
        QHash<int, QByteArray> roles;
        const QMetaObject mo = TaskItem::staticMetaObject;
        for(auto i = 0; i < mo.propertyCount(); i++)
            roles.insert(i, mo.property(i).name());
        return roles;
    }();
    return roleNames;
}

void TaskItem::updatePastDue()
{
    bool pastDue = calculatePastDue();
    if(!m_done && pastDue != m_pastDue) {
        m_pastDue = pastDue;
        emit pastDueChanged();
    }
    if (pastDue) {
        m_pastDueTimer->stop();
    }
}

void TaskItem::updatePastDueTimer()
{
    m_pastDueTimer->setSingleShot(true);
    if(calculatePastDue()) {
        m_pastDueTimer->stop();
    }
    else {
        int interval = QDateTime::currentDateTime().msecsTo(m_dueDate) + 500;
        m_pastDueTimer->start(interval);
    }
}

QDebug operator<<(QDebug debug, const TaskItem &item)
{
    QDebugStateSaver saver(debug);
    debug.nospace() << "TaskItem("
                    << item.description() << ", "
                    << "priority: " << item.priority()
                    << ")";
    return debug;
}

QDebug operator<<(QDebug debug, const TaskItem *item)
{
    QDebugStateSaver saver(debug);
    if (!item) {
        debug << "TaskItem(nullptr)";
        return debug;
    }
    debug << *item;
    return debug;
}
