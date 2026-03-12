#pragma once
#include <QObject>
#include <QQmlEngine>
#include <QRangeModel>
#include <QRangeModelAdapter>
#include <vector>
#include "TaskItem.h"

class TaskBackend : public QObject {
    Q_OBJECT
    QML_ELEMENT

    // Expose the model provided by the adapter
    Q_PROPERTY(QAbstractItemModel* taskModel READ taskModel CONSTANT)

public:
    explicit TaskBackend(QObject *parent = nullptr);

    QAbstractItemModel* taskModel() const;

    Q_INVOKABLE void moveTask(int from, int to);

private:
    QRangeModelAdapter<std::vector<TaskItem*>> m_adapter;
};
