package com.example.meeting_app_api.entity;

import java.time.LocalDateTime;

public class Message {
    
    // メッセージコード
    private String messageCode;
    
    // メッセージ本文
    private String messageText;
    
    // メッセージ種別
    private String messageType;
    
    // 更新日時
    private LocalDateTime updatedAt;

    // ゲッター・セッター
    public String getMessageCode() { return messageCode; }
    public void setMessageCode(String messageCode) { this.messageCode = messageCode; }

    public String getMessageText() { return messageText; }
    public void setMessageText(String messageText) { this.messageText = messageText; }

    public String getMessageType() { return messageType; }
    public void setMessageType(String messageType) { this.messageType = messageType; }

    public LocalDateTime getUpdatedAt() { return updatedAt; }
    public void setUpdatedAt(LocalDateTime updatedAt) { this.updatedAt = updatedAt; }
}