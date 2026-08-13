package com.example.meeting_app_api.service.impl;

import com.example.meeting_app_api.entity.Group;
import com.example.meeting_app_api.entity.GroupMember;
import com.example.meeting_app_api.entity.Meeting;
import com.example.meeting_app_api.entity.Task;
import com.example.meeting_app_api.entity.User;
import com.example.meeting_app_api.mapper.GroupMapper;
import com.example.meeting_app_api.mapper.MeetingMapper;
import com.example.meeting_app_api.mapper.TaskMapper;
import com.example.meeting_app_api.mapper.UserMapper;
import com.example.meeting_app_api.service.DashboardService;
import com.example.meeting_app_api.service.common.TaskUtils;
import org.springframework.stereotype.Service;

import java.util.List;

@Service
public class DashboardServiceImpl implements DashboardService {

    private final MeetingMapper meetingMapper;
    private final TaskMapper taskMapper;
    private final UserMapper userMapper;
    private final GroupMapper groupMapper;

    public DashboardServiceImpl(
            MeetingMapper meetingMapper,
            TaskMapper taskMapper,
            UserMapper userMapper,
            GroupMapper groupMapper) {
        this.meetingMapper = meetingMapper;
        this.taskMapper = taskMapper;
        this.userMapper = userMapper;
        this.groupMapper = groupMapper;
    }

    @Override
    public List<Meeting> getDashboardMeetings(String keyword, boolean showAll) {
        return meetingMapper.findAll(keyword, showAll);
    }

    @Override
    public List<User> getAllUsers() {
        return userMapper.findAll();
    }

    @Override
    public List<Task> getDashboardTasks(List<User> users) {
        List<Task> tasks = taskMapper.findAll();
        TaskUtils.populateAssigneeNames(tasks, users);
        TaskUtils.calculateDueUrgency(tasks);
        return tasks;
    }

    @Override
    public List<Group> getDashboardGroups() {
        List<Group> groups = groupMapper.findAllGroups();
        List<GroupMember> groupMembers = groupMapper.findAllGroupMembers();

        for (Group group : groups) {
            StringBuilder membersSb = new StringBuilder();
            for (GroupMember gm : groupMembers) {
                if (group.getGroupId() != null && group.getGroupId().equals(gm.getGroupId())) {
                    if (membersSb.length() > 0) {
                        membersSb.append(", ");
                    }
                    membersSb.append(gm.getUserEmail());
                }
            }
            group.setMembers(membersSb.toString());
        }
        return groups;
    }
}