package com.example.meeting_app_api.entity;

public class UserPermission {
    
    // メールアドレス
    private String email;
    
    // ユーザーID
    private String userId;
    
    // ユーザー名
    private String userName;
    
    // 役職ID
    private String roleId;
    
    // 役職名
    private String roleName;

    // ゲッター・セッター
    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }
    
    public String getUserName() { return userName; }
    public void setUserName(String userName) { this.userName = userName; }
    
    public String getRoleId() { return roleId; }
    public void setRoleId(String roleId) { this.roleId = roleId; }
    
    public String getRoleName() { return roleName; }
    public void setRoleName(String roleName) { this.roleName = roleName; }
}