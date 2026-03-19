#include "TaskBackend.h"
#include <QDebug>

static int nextPriority() {
    static int priority = 0;
    return ++priority;
}

QDateTime nowAddSecs(int secs) {
    return QDateTime::currentDateTime().addMSecs(secs*1000);
}
static QDateTime sLastWeek(QDateTime::currentDateTime().addDays(-7));
static QDateTime sTomorrow(QDateTime::currentDateTime().addDays(1));

static QObject s_dataParent;
std::vector<TaskItem*> s_data({
    new TaskItem("Empty dishwasher", nextPriority(), sTomorrow, &s_dataParent),
    new TaskItem("Fill Med Planner", nextPriority(), sLastWeek, &s_dataParent),
    new TaskItem("Wash clothes", nextPriority(), nowAddSecs(4), &s_dataParent),
    new TaskItem("Clear table", nextPriority(), nowAddSecs(3), &s_dataParent),
    new TaskItem("Dry clothes", nextPriority(), nowAddSecs(6), &s_dataParent),
    new TaskItem("Load dishwasher", nextPriority(), sTomorrow, &s_dataParent),
    new TaskItem("Fold clothes", nextPriority(), nowAddSecs(8), &s_dataParent),
    new TaskItem("Run dishwasher", nextPriority(), sTomorrow, &s_dataParent),
    new TaskItem("Put clothes away", nextPriority(), nowAddSecs(10), &s_dataParent)
});

TaskBackend::TaskBackend(QObject *parent)
    : QObject(parent)
    // Initialize with sample data
    , m_adapter(std::ref(s_data))
{
    m_adapter.model()->setRoleNames(TaskItem::roleNames());
    m_adapter.model()->setAutoConnectPolicy(QRangeModel::AutoConnectPolicy::Full);
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
