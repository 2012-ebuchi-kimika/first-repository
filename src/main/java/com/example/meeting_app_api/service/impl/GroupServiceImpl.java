package com.example.meeting_app_api.service.impl;

import com.example.meeting_app_api.entity.Group;
import com.example.meeting_app_api.entity.User;
import com.example.meeting_app_api.mapper.GroupMapper;
import com.example.meeting_app_api.mapper.UserMapper;
import com.example.meeting_app_api.service.GroupService;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class GroupServiceImpl implements GroupService {

    private final GroupMapper groupMapper;
    private final UserMapper userMapper;

    public GroupServiceImpl(GroupMapper groupMapper, UserMapper userMapper) {
        this.groupMapper = groupMapper;
        this.userMapper = userMapper;
    }

    @Override
    public Map<String, Object> saveGroup(Map<String, Object> payload) {
        Object idObj = payload.get("groupId");
        Integer groupId = (idObj != null && !idObj.toString().trim().isEmpty()) 
                ? Integer.parseInt(idObj.toString().trim()) 
                : null;
        
        String groupName = ((String) payload.get("groupName")).trim();
        String membersStr = ((String) payload.get("members")).trim();

        String ownerUserId = (String) payload.get("ownerUserId");
        if (ownerUserId == null || ownerUserId.trim().isEmpty()) {
            List<User> existingUsers = userMapper.findAll();
            if (existingUsers != null && !existingUsers.isEmpty()) {
                User firstUser = existingUsers.get(0);
                ownerUserId = (firstUser.getUserId() != null) ? firstUser.getUserId().toString() : firstUser.getEmail();
            } else {
                ownerUserId = "trainee1405@company.com";
            }
        }

        Group group = new Group();
        group.setGroupId(groupId);
        group.setGroupName(groupName);
        group.setOwnerUserId(ownerUserId);

        if (groupId != null) {
            groupMapper.updateGroup(group);
            groupMapper.deleteGroupMembersByGroupId(groupId);
        } else {
            groupMapper.insertGroup(group);
            groupId = group.getGroupId();
        }

        String[] emails = membersStr.split(",");
        for (String email : emails) {
            String trimmedEmail = email.trim();
            if (!trimmedEmail.isEmpty()) {
                groupMapper.insertGroupMember(groupId, trimmedEmail);
            }
        }

        return Map.of(
            "groupId", groupId,
            "groupName", groupName,
            "members", membersStr
        );
    }

    @Override
    public void deleteGroup(Integer groupId) {
        groupMapper.deleteGroupMembersByGroupId(groupId);
        groupMapper.deleteGroup(groupId);
    }
}