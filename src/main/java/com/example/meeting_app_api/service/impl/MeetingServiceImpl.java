package com.example.meeting_app_api.service.impl;

import com.example.meeting_app_api.entity.Meeting;
import com.example.meeting_app_api.entity.Task;
import com.example.meeting_app_api.entity.User;
import com.example.meeting_app_api.mapper.MeetingMapper;
import com.example.meeting_app_api.mapper.TaskMapper;
import com.example.meeting_app_api.mapper.UserMapper;
import com.example.meeting_app_api.service.AiService;
import com.example.meeting_app_api.service.MeetingService;
import com.example.meeting_app_api.service.common.TaskUtils;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;

@Service
public class MeetingServiceImpl implements MeetingService {

    private final MeetingMapper meetingMapper;
    private final TaskMapper taskMapper;
    private final UserMapper userMapper;
    private final AiService aiService;

    public MeetingServiceImpl(MeetingMapper meetingMapper, TaskMapper taskMapper, UserMapper userMapper, AiService aiService) {
        this.meetingMapper = meetingMapper;
        this.taskMapper = taskMapper;
        this.userMapper = userMapper;
        this.aiService = aiService;
    }

    @Override
    public List<Meeting> getAllMeetings(String keyword, boolean showAll) {
        return meetingMapper.findAll(keyword, showAll);
    }

    @Override
    public List<User> getAllUsers() {
        return userMapper.findAll();
    }

    @Override
    public String getSavedAiSummary(Long meetingId, List<Meeting> meetings) {
        if (meetingId == null || meetings == null) return null;
        return meetings.stream()
                .filter(m -> m != null && m.getMeetingId() != null && m.getMeetingId().longValue() == meetingId.longValue())
                .filter(m -> m.getAiSummary() != null && !m.getAiSummary().trim().isEmpty())
                .map(Meeting::getAiSummary)
                .findFirst()
                .orElse(null);
    }

    @Override
    public List<Task> getExistingTasksForMeeting(Long meetingId, List<User> users) {
        if (meetingId == null) return List.of();
        List<Task> existingTasks = taskMapper.findByMeetingId(meetingId);
        TaskUtils.populateAssigneeNames(existingTasks, users);
        return existingTasks;
    }

    @Override
    public Map<String, Object> analyzeTranscript(Long meetingId, String transcript, String personaType) {
        String meetingDate = LocalDate.now().toString();
        if (meetingId != null) {
            List<Meeting> meetings = meetingMapper.findAll(null, true);
            Meeting meeting = meetings.stream()
                    .filter(m -> m != null && m.getMeetingId() != null && m.getMeetingId().longValue() == meetingId.longValue())
                    .findFirst()
                    .orElse(null);

            if (meeting != null && meeting.getStartTime() != null) {
                String rawTime = meeting.getStartTime().toString();
                meetingDate = rawTime.split("T")[0].split(" ")[0];
            }
        }
        return aiService.analyzeTranscript(transcript, personaType, meetingDate);
    }

    @Override
    public void saveSummaryAndTasks(Long meetingId, String aiSummary, String taskTitle, String taskAssignee, String taskDueDate) {
        meetingMapper.updateAiSummary(meetingId, aiSummary);

        if (taskTitle != null && !taskTitle.trim().isEmpty()) {
            String[] titles = taskTitle.split("\\s*/\\s*|\\s*\\\\\\s*");
            String[] assignees = (taskAssignee != null) ? taskAssignee.split("\\s*/\\s*|\\s*\\\\\\s*") : new String[0];
            String[] dueDates = (taskDueDate != null) ? taskDueDate.split("\\s*/\\s*|\\s*\\\\\\s*") : new String[0];

            for (int i = 0; i < titles.length; i++) {
                String content = titles[i].trim();
                if (content.isEmpty()) continue;

                String assignee = (i < assignees.length) ? assignees[i].trim() : "";
                String rawDueDate = (i < dueDates.length) ? dueDates[i].trim() : "";

                String dueDate = null;
                if (rawDueDate != null && rawDueDate.matches("\\d{4}-\\d{2}-\\d{2}")) {
                    dueDate = rawDueDate;
                }

                taskMapper.insertTask(meetingId, content, assignee, dueDate, "TODO");
            }
        }
    }

    @Override
    public Integer createMeeting(Meeting meeting) {
        if (meeting.getPersonaType() == null || meeting.getPersonaType().trim().isEmpty()) {
            meeting.setPersonaType("default");
        }
        meetingMapper.insert(meeting);
        return meeting.getMeetingId();
    }

    // ★ 追加：編集・更新処理
    @Override
    public void updateMeeting(Meeting meeting) {
        meetingMapper.update(meeting);
    }

    // ★ 追加：削除処理
    @Override
    public void deleteMeeting(Integer meetingId) {
        meetingMapper.deleteById(meetingId);
    }

    // ★ 追加：ID指定による1件取得
    @Override
    public Meeting getMeetingById(Integer meetingId) {
        return meetingMapper.findById(meetingId);
    }
}