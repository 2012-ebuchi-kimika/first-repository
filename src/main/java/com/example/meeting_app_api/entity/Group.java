package com.example.meeting_app_api.entity;

import java.time.LocalDateTime;

public class Group {

    // グループID
    private Integer groupId;

    // グループ名
    private String groupName;
    
    // 所有者ユーザーID
    private String ownerUserId;
    
    // 作成日時
    private LocalDateTime createdAt;

    // ゲッター・セッター
    public Integer getGroupId() { return groupId; }
    public void setGroupId(Integer groupId) { this.groupId = groupId; }

    public String getGroupName() { return groupName; }
    public void setGroupName(String groupName) { this.groupName = groupName; }

    public String getOwnerUserId() { return ownerUserId; }
    public void setOwnerUserId(String ownerUserId) { this.ownerUserId = ownerUserId; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}