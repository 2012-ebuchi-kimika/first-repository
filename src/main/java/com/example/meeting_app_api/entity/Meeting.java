package com.example.meeting_app_api.entity;

import java.time.LocalDateTime;

public class Meeting {

    // 会議ID
    private Integer meetingId;
    
    // 会議タイトル
    private String title;
    
    // 開催日時
    private LocalDateTime startTime;
    
    // Google Meet URL
    private String meetUrl;
    
    // 文字起こし原文
    private String transcript;
    
    // AI要約テキスト
    private String aiSummary;
    
    // ペルソナ（トーン）種別
    private String personaType;

    // 会議参加者メールアドレス（カンマ区切り文字列）
    private String attendeeEmails;
    
    // Google カレンダーのイベントID
    private String googleEventId;
    
    // 作成日時
    private LocalDateTime createdAt;

    // ゲッター・セッター
    public Integer getMeetingId() { return meetingId; }
    public void setMeetingId(Integer meetingId) { this.meetingId = meetingId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public LocalDateTime getStartTime() { return startTime; }
    public void setStartTime(LocalDateTime startTime) { this.startTime = startTime; }

    public String getMeetUrl() { return meetUrl; }
    public void setMeetUrl(String meetUrl) { this.meetUrl = meetUrl; }

    public String getTranscript() { return transcript; }
    public void setTranscript(String transcript) { this.transcript = transcript; }

    public String getAiSummary() { return aiSummary; }
    public void setAiSummary(String aiSummary) { this.aiSummary = aiSummary; }

    public String getPersonaType() { return personaType; }
    public void setPersonaType(String personaType) { this.personaType = personaType; }

    public String getAttendeeEmails() { return attendeeEmails; }
    public void setAttendeeEmails(String attendeeEmails) { this.attendeeEmails = attendeeEmails; }

    public String getGoogleEventId() { return googleEventId; }
    public void setGoogleEventId(String googleEventId) { this.googleEventId = googleEventId; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}