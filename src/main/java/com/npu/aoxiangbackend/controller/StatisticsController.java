package com.npu.aoxiangbackend.controller;

import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import com.npu.aoxiangbackend.service.UserService;
import com.npu.aoxiangbackend.service.SurveyService;
import cn.dev33.satoken.util.SaResult;
import com.npu.aoxiangbackend.exception.business.UserServiceException;
import com.npu.aoxiangbackend.exception.internal.DatabaseAccessException;

import java.util.Map;
import java.util.HashMap;

@RestController
public class StatisticsController {

    private final UserService userService;
    private final SurveyService surveyService;

    public StatisticsController(UserService userService, SurveyService surveyService) {
        this.userService = userService;
        this.surveyService = surveyService;
    }

    @RequestMapping(value = "/api/statistics", method = {RequestMethod.GET, RequestMethod.POST})
    public SaResult getSystemStatistics(@RequestParam(required = true) String token) {
        try {
            Map<String, Long> statistics = new HashMap<>();
            statistics.put("totalUsers", userService.getUserNum(token));
            statistics.put("totalSurveys", surveyService.getTotalSurveys());
            statistics.put("approvedSurveys", surveyService.getApprovedSurveys());
            return SaResult.ok().setData(statistics);
        } catch (UserServiceException | DatabaseAccessException e) {
            return SaResult.error(e.getMessage());
        }
    }
}
