package com.example.meeting_app_api.service;

import com.example.meeting_app_api.entity.Meeting;
import com.example.meeting_app_api.entity.Task;
import com.example.meeting_app_api.entity.User;

import java.util.List;
import java.util.Map;

public interface MeetingService {
    List<Meeting> getAllMeetings(String keyword, boolean showAll);
    List<User> getAllUsers();
    String getSavedAiSummary(Long meetingId, List<Meeting> meetings);
    List<Task> getExistingTasksForMeeting(Long meetingId, List<User> users);
    Map<String, Object> analyzeTranscript(Long meetingId, String transcript, String personaType);
    void saveSummaryAndTasks(Long meetingId, String aiSummary, String taskTitle, String taskAssignee, String taskDueDate);
    Integer createMeeting(Meeting meeting);
}