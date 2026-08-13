package com.example.meeting_app_api.service;

import java.util.Map;

public interface GroupService {
    Map<String, Object> saveGroup(Map<String, Object> payload);
    void deleteGroup(Integer groupId);
}