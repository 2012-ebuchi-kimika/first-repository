package com.example.meeting_app_api.service;

import com.example.meeting_app_api.entity.Group;
import com.example.meeting_app_api.entity.Meeting;
import com.example.meeting_app_api.entity.Task;
import com.example.meeting_app_api.entity.User;

import java.util.List;

public interface DashboardService {
    List<Meeting> getDashboardMeetings(String keyword, boolean showAll);
    List<User> getAllUsers();
    List<Task> getDashboardTasks(List<User> users);
    List<Group> getDashboardGroups();
}