#include "TaskBackend.h"
#include <QDebug>

TaskBackend::TaskBackend(QObject *parent)
    : QObject(parent)
    , m_data({
        new TaskItem("Buy groceries", this),
        new TaskItem("Walk the dog", this),
        new TaskItem("Empty dishwasher", this),
        new TaskItem("Fill Med Planner", this),
        new TaskItem("Wash clothes", this),
        new TaskItem("Clear table", this),
        new TaskItem("Dry clothes", this),
        new TaskItem("Load dishwasher", this),
        new TaskItem("Fold clothes", this),
        new TaskItem("Run dishwasher", this),
        new TaskItem("Empty trash", this)
    })
    , m_adapter(std::ref(m_data))
{
}

QAbstractItemModel* TaskBackend::taskModel() const
{
    return m_adapter.model();
}

void TaskBackend::moveTask(int from, int to)
{
    qDebug().noquote().nospace() << "TaskBackend::moveTask(" << from << ", " << to << ")";
    if (from == to) return;
    m_adapter.moveRows(from, 1, to > from ? to + 1 : to);
    dumpModel();
}

void TaskBackend::dumpModel() const
{
    qDebug() << m_adapter.range();
}
