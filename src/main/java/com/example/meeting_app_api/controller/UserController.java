package com.example.meeting_app_api.controller;

import com.example.meeting_app_api.entity.User;
import com.example.meeting_app_api.mapper.UserMapper;
import com.example.meeting_app_api.service.UserService;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserMapper userMapper;
    private final UserService userService;

    // コンストラクタで UserService も受け取る
    public UserController(UserMapper userMapper, UserService userService) {
        this.userMapper = userMapper;
        this.userService = userService;
    }

    @GetMapping
    public List<User> getMessages() {
        return userMapper.findAll();
    }

    /**
     * グループ管理権限チェック API
     * URL: /api/users/check-permission?email=xxx
     */
    @GetMapping("/check-permission")
    public Map<String, Boolean> checkPermission(@RequestParam(required = false) String email) {
        boolean hasPermission = userService.hasGroupManagementPermission(email);

        Map<String, Boolean> response = new HashMap<>();
        response.put("hasPermission", hasPermission);
        
        // 返却JSON形式: {"hasPermission": true} または {"hasPermission": false}
        return response;
    }
}