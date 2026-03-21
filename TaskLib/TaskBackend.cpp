#include "TaskBackend.h"

static const QStringList s_data {
    {"Buy groceries"},
    {"Walk the dog"},
    {"Empty dishwasher"},
    {"Wash clothes"},
    {"Clear table"},
    {"Dry clothes"},
    {"Load dishwasher"},
    {"Fold clothes"},
    {"Run dishwasher"},
    {"Empty trash"}
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
