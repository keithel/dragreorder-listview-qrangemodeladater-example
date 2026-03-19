#pragma once

#include <QByteArray>
#include <QDateTime>
#include <QDebug>
#include <QObject>
#include <QString>
#include <QQmlEngine>
#include <QRangeModel>

class QTimer;

class TaskItem : public QObject {
    Q_OBJECT
    QML_ELEMENT
    QML_UNCREATABLE("TaskItem is managed by the C++ Backend")

    Q_PROPERTY(QString description READ description WRITE setDescription NOTIFY descriptionChanged FINAL)
    Q_PROPERTY(int priority READ priority WRITE setPriority NOTIFY priorityChanged FINAL)
    Q_PROPERTY(QDateTime dueDate READ dueDate WRITE setDueDate NOTIFY dueDateChanged FINAL)
    Q_PROPERTY(bool pastDue READ pastDue NOTIFY pastDueChanged FINAL)
    Q_PROPERTY(bool done READ done WRITE setDone NOTIFY doneChanged FINAL)

public:
    explicit TaskItem(const QString &description = "", int priority = 0,
                      QDateTime dueDate = QDateTime::currentDateTime(), QObject *parent = nullptr);

    inline QString description() const { return m_description; }
    inline int priority() const { return m_priority; }
    inline QDateTime dueDate() const { return m_dueDate; }
    inline bool pastDue() const { return m_pastDue; }
    inline bool done() const { return m_done; }

    void setDescription(const QString &description);
    void setPriority(int priority);
    void setDueDate(const QDateTime &newDueDate);
    void setDone(bool done);

public:
    static QHash<int, QByteArray> roleNames();

signals:
    void descriptionChanged();
    void priorityChanged();
    void dueDateChanged();
    void pastDueChanged();
    void doneChanged();

protected:
    void updatePastDue();
    void updatePastDueTimer();
    bool calculatePastDue() { return QDateTime::currentDateTime() > m_dueDate; }

private:
    QString m_description;
    int m_priority;
    QDateTime m_dueDate;
    bool m_pastDue = calculatePastDue();
    bool m_done = false;
    QTimer *m_pastDueTimer;
};

template<> struct QRangeModel::RowOptions<TaskItem>
{
    static constexpr auto rowCategory = QRangeModel::RowCategory::MultiRoleItem;
};

QDebug operator<<(QDebug debug, const TaskItem &item);
QDebug operator<<(QDebug debug, const TaskItem *item);
