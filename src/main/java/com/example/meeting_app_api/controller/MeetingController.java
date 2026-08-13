package com.example.meeting_app_api.controller;

import com.example.meeting_app_api.entity.Meeting;
import com.example.meeting_app_api.entity.Task;
import com.example.meeting_app_api.entity.User;
import com.example.meeting_app_api.service.MeetingService;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@Controller
public class MeetingController {

    private final MeetingService meetingService;

    public MeetingController(MeetingService meetingService) {
        this.meetingService = meetingService;
    }

    @GetMapping("/meetings/detail")
    public String showMeetingDetail(
            @RequestParam(name = "id", required = false) Long id, 
            Model model) {
        
        List<Meeting> meetings = meetingService.getAllMeetings(null, true);
        model.addAttribute("meetings", meetings);
        model.addAttribute("selectedMeetingId", id);

        List<User> users = meetingService.getAllUsers();
        model.addAttribute("users", users);

        if (id != null) {
            model.addAttribute("savedAiSummary", meetingService.getSavedAiSummary(id, meetings));
            List<Task> existingTasks = meetingService.getExistingTasksForMeeting(id, users);
            model.addAttribute("existingTasks", existingTasks);
        }

        return "meeting-detail";
    }

    @PostMapping("/meetings/analyze")
    @ResponseBody
    public Map<String, Object> analyzeMeeting(
            @RequestParam(name = "meetingId", required = false) Long meetingId,
            @RequestParam("transcript") String transcript,
            @RequestParam(name = "personaType", defaultValue = "default") String personaType) {
        
        return meetingService.analyzeTranscript(meetingId, transcript, personaType);
    }

    @PostMapping("/meetings/save-summary")
    public String saveSummary(
            @RequestParam("meetingId") Long meetingId,
            @RequestParam("aiSummary") String aiSummary,
            @RequestParam(name = "taskTitle", required = false) String taskTitle,
            @RequestParam(name = "taskAssignee", required = false) String taskAssignee,
            @RequestParam(name = "taskDueDate", required = false) String taskDueDate) {

        meetingService.saveSummaryAndTasks(meetingId, aiSummary, taskTitle, taskAssignee, taskDueDate);
        return "redirect:/meetings/detail?id=" + meetingId;
    }

    @GetMapping("/api/meetings")
    @ResponseBody
    public List<Meeting> getMeetings(
            @RequestParam(required = false) String keyword,
            @RequestParam(name = "showAll", required = false, defaultValue = "false") boolean showAll) {
        return meetingService.getAllMeetings(keyword, showAll);
    }

    @PostMapping("/meetings/create")
    public String createMeeting(
            @ModelAttribute Meeting meeting,
            @RequestParam(name = "actionType", defaultValue = "saveOnly") String actionType) {

        Integer meetingId = meetingService.createMeeting(meeting);

        if ("goToDetail".equals(actionType)) {
            return "redirect:/meetings/detail?id=" + meetingId;
        } else {
            return "redirect:/dashboard";
        }
    }
}