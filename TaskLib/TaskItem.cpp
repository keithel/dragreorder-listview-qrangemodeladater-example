#include "TaskItem.h"
#include <QTimer>

TaskItem::TaskItem(const QString &description, QDateTime dueDate, QObject *parent)
    : QObject(parent)
    , m_description(description)
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
    debug.nospace() << "TaskItem(" << item.description() << ")";
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
