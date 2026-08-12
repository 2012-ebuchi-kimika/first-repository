package com.example.meeting_app_api.entity;

import java.time.LocalDateTime;

public class User {

    // ユーザーID
    private String userId;

    // ユーザー名
    private String name;

    // メールアドレス
    private String email;
    
    // Googleリフレッシュトークン
    private String googleRefreshToken;
    
    // 作成日時
    private LocalDateTime createdAt;

    // 未完了タスク数（画面表示用の保持フィールド）
    private Integer pendingTaskCount = 0;

    // ゲッター・セッター
    public String getUserId() { return userId; }
    public void setUserId(String userId) { this.userId = userId; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getGoogleRefreshToken() { return googleRefreshToken; }
    public void setGoogleRefreshToken(String googleRefreshToken) { this.googleRefreshToken = googleRefreshToken; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }

    public Integer getPendingTaskCount() { return pendingTaskCount; }
    public void setPendingTaskCount(Integer pendingTaskCount) { this.pendingTaskCount = pendingTaskCount; }
}