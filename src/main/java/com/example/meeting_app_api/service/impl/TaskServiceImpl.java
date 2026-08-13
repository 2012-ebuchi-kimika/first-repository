package com.example.meeting_app_api.service.impl;

import com.example.meeting_app_api.entity.Task;
import com.example.meeting_app_api.entity.User;
import com.example.meeting_app_api.mapper.TaskMapper;
import com.example.meeting_app_api.mapper.UserMapper;
import com.example.meeting_app_api.service.TaskService;
import com.example.meeting_app_api.service.common.TaskUtils;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class TaskServiceImpl implements TaskService {

    private final TaskMapper taskMapper;
    private final UserMapper userMapper;

    public TaskServiceImpl(TaskMapper taskMapper, UserMapper userMapper) {
        this.taskMapper = taskMapper;
        this.userMapper = userMapper;
    }

    @Override
    public List<Task> getAllTasks() {
        return taskMapper.findAll();
    }

    @Override
    public Task getTaskById(Long taskId) {
        return taskMapper.findById(taskId);
    }

    @Override
    public List<User> getUsersWithPendingTaskCount() {
        List<Task> allTasks = taskMapper.findAll();
        List<User> users = userMapper.findAll();
        TaskUtils.calculatePendingTasksForUsers(users, allTasks);
        return users;
    }

    @Override
    public void updateTask(Long taskId, String taskContent, String assigneeEmail, String dueDate, String status) {
        if (dueDate != null && dueDate.trim().isEmpty()) {
            dueDate = null;
        }
        taskMapper.updateTask(taskId, taskContent, assigneeEmail, dueDate, status);
    }
}