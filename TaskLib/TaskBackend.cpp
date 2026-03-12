#include "TaskBackend.h"
#include <QDebug>

static int nextPriority() {
    static int priority = 0;
    return ++priority;
}

std::vector<TaskItem*> s_data({
    new TaskItem("Empty dishwasher", nextPriority()),
    new TaskItem("Wash clothes", nextPriority()),
    new TaskItem("Clear table", nextPriority()),
    new TaskItem("Dry clothes", nextPriority()),
    new TaskItem("Load dishwasher", nextPriority()),
    new TaskItem("Fold clothes", nextPriority()),
    new TaskItem("Run dishwasher", nextPriority()),
    new TaskItem("Put clothes away", nextPriority())
});

TaskBackend::TaskBackend(QObject *parent)
    : QObject(parent)
    // Initialize with sample data
    , m_adapter(std::ref(s_data))
{
    qDebug() << m_adapter.range();
}

QAbstractItemModel* TaskBackend::taskModel() const
{
    return m_adapter.model();
}

void TaskBackend::moveTask(int from, int to)
{
    if (from == to) return;
    qDebug() << "Moving task" << m_adapter.range()[from]->description() << "at index" << from << "to index" << to;
    bool rowMoved = m_adapter.moveRow(from, to > from ? to + 1 : to);
    qDebug() << "Row moved?" << rowMoved << "adapter data:" << m_adapter.range();
}
