package com.example.meeting_app_api.entity;

public class GroupMember {

    // グループメンバーID
    private Integer groupMemberId;
    
    // グループID
    private Integer groupId;
    
    // メンバーメールアドレス
    private String userEmail;
    
    // メンバー名
    private String name;
    
    // 役割
    private String role;

    // ゲッター・セッター
    public Integer getGroupMemberId() { return groupMemberId; }
    public void setGroupMemberId(Integer groupMemberId) { this.groupMemberId = groupMemberId; }

    public Integer getGroupId() { return groupId; }
    public void setGroupId(Integer groupId) { this.groupId = groupId; }

    public String getUserEmail() { return userEmail; }
    public void setUserEmail(String userEmail) { this.userEmail = userEmail; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }
}