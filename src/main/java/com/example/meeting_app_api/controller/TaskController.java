package com.example.meeting_app_api.controller;

import com.example.meeting_app_api.entity.Task;
import com.example.meeting_app_api.mapper.TaskMapper;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController
@RequestMapping("/api/tasks")
public class TaskController {

    private final TaskMapper taskMapper;

    public TaskController(TaskMapper taskMapper) {
        this.taskMapper = taskMapper;
    }

    @GetMapping
    public List<Task> getTasks() {
        return taskMapper.findAll();
    }
}