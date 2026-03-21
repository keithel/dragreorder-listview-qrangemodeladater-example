#include "TaskBackend.h"
#include <QStringList>
#include <QDebug>

static const QStringList s_data {
    "Buy groceries",
    "Walk the dog",
    "Empty dishwasher",
    "Wash clothes",
    "Clear table",
    "Dry clothes",
    "Load dishwasher",
    "Fold clothes",
    "Run dishwasher",
    "Empty trash"
};

TaskBackend::TaskBackend(QObject *parent)
    : QObject(parent)
    // Pass by reference so the model reads from s_data.
    // Do NOT modify s_data directly after this point.
    , m_model(std::ref(s_data))
{
}

QAbstractItemModel* TaskBackend::taskModel() const
{
    return const_cast<QRangeModel*>(&m_model);
}

void TaskBackend::dumpModel() const
{
    int rows = m_model.rowCount();
    int cols = m_model.columnCount();
    if (cols > 1) {
        qDebug() << "Unexpected number of columns!";
        return;
    }

    QString modelStr;
    QTextStream modelStream(&modelStr);
    modelStream << "{ ";
    for (auto r = 0; r < rows; r++) {
        if (r > 0)
            modelStream << ", ";

        QModelIndex idx = m_model.index(r, 0);
        if (!idx.isValid()) {
            modelStream << "index-invalid";
            continue;
        }

        if (idx.data().typeId() != QMetaType::QString) {
            modelStream << "unsupported-type " << idx.data().typeName();
            continue;
        }

        modelStream << "\"" << idx.data().toString() << "\"";
    }
    modelStream << " }";
    qDebug().noquote() << modelStr;
}
