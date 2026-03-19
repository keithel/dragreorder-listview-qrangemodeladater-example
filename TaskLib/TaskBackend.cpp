#include "TaskBackend.h"
#include <QDebug>

QDateTime nowAddSecs(int secs) {
    return QDateTime::currentDateTime().addMSecs(secs*1000);
}
static QDateTime sLastWeek(QDateTime::currentDateTime().addDays(-7));
static QDateTime sTomorrow(QDateTime::currentDateTime().addDays(1));

TaskBackend::TaskBackend(QObject *parent)
    : QObject(parent)
    , m_data({
        new TaskItem("Buy groceries", nowAddSecs(7), this),
        new TaskItem("Walk the dog", sLastWeek, this),
        new TaskItem("Empty dishwasher", sTomorrow, this),
        new TaskItem("Fill Med Planner", sLastWeek, this),
        new TaskItem("Wash clothes", nowAddSecs(4), this),
        new TaskItem("Clear table", nowAddSecs(3), this),
        new TaskItem("Dry clothes", nowAddSecs(6), this),
        new TaskItem("Load dishwasher", sTomorrow, this),
        new TaskItem("Fold clothes", nowAddSecs(8), this),
        new TaskItem("Run dishwasher", sTomorrow, this),
        new TaskItem("Empty trash", nowAddSecs(10), this)
    })
    , m_adapter(std::ref(m_data))
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
        qDebug() << "Row moved";
    else
        qDebug() << "Row didn't move";

    dumpModel();
}

void TaskBackend::dumpModel() const
{
    qDebug() << m_adapter.range();
}
