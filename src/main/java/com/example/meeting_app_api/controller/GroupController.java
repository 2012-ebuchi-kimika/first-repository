package com.example.meeting_app_api.controller;

import com.example.meeting_app_api.service.GroupService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.Map;

@RestController
@RequestMapping("/api/groups")
public class GroupController {

    private final GroupService groupService;

    public GroupController(GroupService groupService) {
        this.groupService = groupService;
    }

    @PostMapping("/save")
    public ResponseEntity<?> saveGroup(@RequestBody Map<String, Object> payload) {
        Map<String, Object> response = groupService.saveGroup(payload);
        return ResponseEntity.ok(response);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteGroup(@PathVariable("id") Integer id) {
        groupService.deleteGroup(id);
        return ResponseEntity.ok().build();
    }
}