package com.example.meeting_app_api.controller;

import com.example.meeting_app_api.entity.Task;
import com.example.meeting_app_api.entity.User;
import com.example.meeting_app_api.service.TaskService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@Controller
public class TaskController {

    private final TaskService taskService;

    public TaskController(TaskService taskService) {
        this.taskService = taskService;
    }

    @GetMapping("/api/tasks")
    @ResponseBody
    public List<Task> getTasks() {
        return taskService.getAllTasks();
    }

    @GetMapping("/tasks/detail")
    public String showTaskDetail(@RequestParam("id") Long taskId, Model model) {
        Task task = taskService.getTaskById(taskId);
        model.addAttribute("task", task);

        List<User> users = taskService.getUsersWithPendingTaskCount();
        model.addAttribute("users", users);

        return "task-detail";
    }

    @PostMapping("/tasks/update")
    public String updateTask(
            @RequestParam("taskId") Long taskId,
            @RequestParam("taskContent") String taskContent,
            @RequestParam(name = "assigneeEmail", required = false) String assigneeEmail,
            @RequestParam(name = "dueDate", required = false) String dueDate,
            @RequestParam("status") String status) {

        taskService.updateTask(taskId, taskContent, assigneeEmail, dueDate, status);
        return "redirect:/dashboard";
    }
}