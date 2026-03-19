#include "TaskBackend.h"
#include <QDebug>

QDateTime nowAddSecs(int secs) {
    return QDateTime::currentDateTime().addMSecs(secs*1000);
}
static QDateTime sLastWeek(QDateTime::currentDateTime().addDays(-7));
static QDateTime sTomorrow(QDateTime::currentDateTime().addDays(1));

static QObject s_dataParent;
std::vector<TaskItem*> s_data({
    new TaskItem("Buy groceries", nowAddSecs(7), &s_dataParent),
    new TaskItem("Walk the dog", sLastWeek, &s_dataParent),
    new TaskItem("Empty dishwasher", sTomorrow, &s_dataParent),
    new TaskItem("Fill Med Planner", sLastWeek, &s_dataParent),
    new TaskItem("Wash clothes", nowAddSecs(4), &s_dataParent),
    new TaskItem("Clear table", nowAddSecs(3), &s_dataParent),
    new TaskItem("Dry clothes", nowAddSecs(6), &s_dataParent),
    new TaskItem("Load dishwasher", sTomorrow, &s_dataParent),
    new TaskItem("Fold clothes", nowAddSecs(8), &s_dataParent),
    new TaskItem("Run dishwasher", sTomorrow, &s_dataParent),
    new TaskItem("Empty trash", nowAddSecs(10), &s_dataParent)
});

TaskBackend::TaskBackend(QObject *parent)
    : QObject(parent)
    , m_adapter(std::ref(s_data))
{
    qDebug() << m_adapter.range();
    m_adapter.model()->setAutoConnectPolicy(QRangeModel::AutoConnectPolicy::Full);
}

QAbstractItemModel* TaskBackend::taskModel() const
{
    return m_adapter.model();
}

void TaskBackend::moveTask(int from, int to)
{
    qDebug().noquote().nospace() << "TaskBackend::moveTask(" << from << ", " << to << ")";
    if (from == to) return;
    qDebug() << "Moving task" << m_adapter.range()[from]->description() << "at index" << from << "to index" << to;
    bool rowMoved = m_adapter.moveRow(from, to > from ? to + 1 : to);
    if (rowMoved)
        qDebug() << "Row moved, adapter data:" << m_adapter.range();
    else
        qDebug() << "Row didn't move";
}
