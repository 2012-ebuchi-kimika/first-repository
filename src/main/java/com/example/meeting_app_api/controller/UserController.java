package com.example.meeting_app_api.controller;

import com.example.meeting_app_api.entity.User;
import com.example.meeting_app_api.mapper.UserMapper;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController
@RequestMapping("/api/users")
public class UserController {

    private final UserMapper userMapper;

    // コンストラクター定義
    public UserController(UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    @GetMapping
    public List<User> getMessages() {
        return userMapper.findAll();
    }
}