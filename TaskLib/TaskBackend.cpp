#include "TaskBackend.h"
#include <QDebug>

static QObject s_dataParent;
std::vector<TaskItem*> s_data({
    new TaskItem("Buy groceries", &s_dataParent),
    new TaskItem("Walk the dog", &s_dataParent),
    new TaskItem("Empty dishwasher", &s_dataParent),
    new TaskItem("Fill Med Planner", &s_dataParent),
    new TaskItem("Wash clothes", &s_dataParent),
    new TaskItem("Clear table", &s_dataParent),
    new TaskItem("Dry clothes", &s_dataParent),
    new TaskItem("Load dishwasher", &s_dataParent),
    new TaskItem("Fold clothes", &s_dataParent),
    new TaskItem("Run dishwasher", &s_dataParent),
    new TaskItem("Empty trash", &s_dataParent)
});

TaskBackend::TaskBackend(QObject *parent)
    : QObject(parent)
    , m_adapter(std::ref(s_data))
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
}
