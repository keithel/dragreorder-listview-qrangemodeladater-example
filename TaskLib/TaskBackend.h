#pragma once

#include <QObject>
#include <QQmlEngine>
#include <QRangeModel>

class TaskBackend : public QObject {
    Q_OBJECT
    QML_ELEMENT

    Q_PROPERTY(QAbstractItemModel* taskModel READ taskModel CONSTANT)

public:
    explicit TaskBackend(QObject *parent = nullptr);

    QAbstractItemModel* taskModel() const;

private:
    QRangeModel m_model;
};
