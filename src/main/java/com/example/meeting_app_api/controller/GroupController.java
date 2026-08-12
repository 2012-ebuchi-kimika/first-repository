package com.example.meeting_app_api.controller;

import com.example.meeting_app_api.entity.Group;
import com.example.meeting_app_api.entity.User;
import com.example.meeting_app_api.mapper.GroupMapper;
import com.example.meeting_app_api.mapper.UserMapper;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/groups")
public class GroupController {

    private final GroupMapper groupMapper;
    private final UserMapper userMapper;

    public GroupController(GroupMapper groupMapper, UserMapper userMapper) {
        this.groupMapper = groupMapper;
        this.userMapper = userMapper;
    }

    // ★ 非同期グループ保存・更新API
    @PostMapping("/save")
    public ResponseEntity<?> saveGroup(@RequestBody Map<String, Object> payload) {
        Object idObj = payload.get("groupId");
        Integer groupId = (idObj != null && !idObj.toString().trim().isEmpty()) 
                ? Integer.parseInt(idObj.toString().trim()) 
                : null;
        
        String groupName = ((String) payload.get("groupName")).trim();
        String membersStr = ((String) payload.get("members")).trim();

        // ★ 外部キー制約（FOREIGN KEY）エラー防止用：DBに実在するユーザーIDを取得・設定
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
            // 編集更新
            groupMapper.updateGroup(group);
            groupMapper.deleteGroupMembersByGroupId(groupId);
        } else {
            // 新規作成
            groupMapper.insertGroup(group);
            groupId = group.getGroupId();
        }

        // メンバー紐付け登録
        String[] emails = membersStr.split(",");
        for (String email : emails) {
            String trimmedEmail = email.trim();
            if (!trimmedEmail.isEmpty()) {
                groupMapper.insertGroupMember(groupId, trimmedEmail);
            }
        }

        return ResponseEntity.ok(Map.of(
            "groupId", groupId,
            "groupName", groupName,
            "members", membersStr
        ));
    }

    // ★ 非同期グループ削除API
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteGroup(@PathVariable("id") Integer id) {
        groupMapper.deleteGroupMembersByGroupId(id);
        groupMapper.deleteGroup(id);
        return ResponseEntity.ok().build();
    }
}