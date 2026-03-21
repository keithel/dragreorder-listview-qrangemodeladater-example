#pragma once

#include <QDebug>
#include <QObject>
#include <QString>
#include <QQmlEngine>
#include <QRangeModel>

class TaskItem : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("TaskItem is managed by the C++ Backend")

    Q_PROPERTY(QString description READ description WRITE setDescription NOTIFY descriptionChanged FINAL)

public:
    explicit TaskItem(const QString &description = "", QObject *parent = nullptr);

    inline QString description() const { return m_description; }
    void setDescription(const QString &description);

signals:
    void descriptionChanged();

private:
    QString m_description;
};

template<> struct QRangeModel::RowOptions<TaskItem>
{
    static constexpr auto rowCategory = QRangeModel::RowCategory::MultiRoleItem;
};

QDebug operator<<(QDebug debug, const TaskItem &item);
QDebug operator<<(QDebug debug, const TaskItem *item);
