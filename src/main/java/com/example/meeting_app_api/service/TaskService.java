package com.example.meeting_app_api.service;

import com.example.meeting_app_api.entity.Task;
import com.example.meeting_app_api.entity.User;

import java.util.List;

public interface TaskService {
    List<Task> getAllTasks();
    Task getTaskById(Long taskId);
    List<User> getUsersWithPendingTaskCount();
    void updateTask(Long taskId, String taskContent, String assigneeEmail, String dueDate, String status);
}