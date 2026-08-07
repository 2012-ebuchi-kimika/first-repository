package com.example.meeting_app_api.controller;

import com.example.meeting_app_api.entity.Message;
import com.example.meeting_app_api.mapper.MessageMapper;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import java.util.List;

@RestController
@RequestMapping("/api/messages")
public class MessageController {

    private final MessageMapper messageMapper;

    // コンストラクター定義
    public MessageController(MessageMapper messageMapper) {
        this.messageMapper = messageMapper;
    }

    @GetMapping
    public List<Message> getMessages() {
        return messageMapper.findAll();
    }
}