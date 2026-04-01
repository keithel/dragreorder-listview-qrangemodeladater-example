#include "TaskItem.h"

TaskItem::TaskItem(const QString &description, QObject *parent)
    : QObject(parent)
    , m_description(description)
{
}

void TaskItem::setDescription(const QString &description)
{
    if (m_description == description)
        return;

    m_description = description;
    emit descriptionChanged();
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
