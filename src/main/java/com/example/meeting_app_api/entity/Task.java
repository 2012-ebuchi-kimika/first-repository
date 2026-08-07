package com.example.meeting_app_api.entity;

import java.time.LocalDate;
import java.time.LocalDateTime;

public class Task {

    // タスクID
    private Integer taskId;
    
    // 紐づく会議ID
    private Integer meetingId;
    
    // 担当者メールアドレス
    private String assigneeEmail;
    
    // タスク内容
    private String taskContent;
    
    // 履行期限
    private LocalDate dueDate;
    
    // ステータス
    private String status;
    
    // 作成日時
    private LocalDateTime createdAt;
    
    // 更新日時
    private LocalDateTime updatedAt;

    // 会議名
    private String meetingTitle;

    // ゲッター・セッター
    public Integer getTaskId() { return taskId; }
    public void setTaskId(Integer taskId) { this.taskId = taskId; }

    public Integer getMeetingId() { return meetingId; }
    public void setMeetingId(Integer meetingId) { this.meetingId = meetingId; }

    public String getAssigneeEmail() { return assigneeEmail; }
    public void setAssigneeEmail(String assigneeEmail) { this.assigneeEmail = assigneeEmail; }

    public String getTaskContent() { return taskContent; }
    public void setTaskContent(String taskContent) { this.taskContent = taskContent; }

    public LocalDate getDueDate() { return dueDate; }
    public void setDueDate(LocalDate dueDate) { this.dueDate = dueDate; }

    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }

    public String getMeetingTitle() { return meetingTitle; }
    public void setMeetingTitle(String meetingTitle) { this.meetingTitle = meetingTitle; }
}