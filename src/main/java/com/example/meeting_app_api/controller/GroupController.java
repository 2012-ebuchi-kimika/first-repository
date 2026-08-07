package com.example.meeting_app_api.controller;

import com.example.meeting_app_api.entity.Group;
import com.example.meeting_app_api.entity.GroupMember;
import com.example.meeting_app_api.mapper.GroupMapper;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController
@RequestMapping("/api/groups")
public class GroupController {

    private final GroupMapper groupMapper;

    public GroupController(GroupMapper groupMapper) {
        this.groupMapper = groupMapper;
    }

    // グループ一覧取得
    @GetMapping
    public List<Group> getGroups() {
        return groupMapper.findAllGroups();
    }

    // グループメンバー一覧取得
    @GetMapping("/members")
    public List<GroupMember> getGroupMembers() {
        return groupMapper.findAllGroupMembers();
    }
}