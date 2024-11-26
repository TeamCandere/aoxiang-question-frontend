package com.npu.aoxiangbackend.controller;

import cn.dev33.satoken.util.SaResult;
import com.npu.aoxiangbackend.exception.business.BusinessException;
import com.npu.aoxiangbackend.exception.business.SurveyServiceException;
import com.npu.aoxiangbackend.exception.business.UserServiceException;
import com.npu.aoxiangbackend.exception.internal.DatabaseAccessException;
import com.npu.aoxiangbackend.model.Survey;
import com.npu.aoxiangbackend.protocol.EditSurveyRequest;
import com.npu.aoxiangbackend.service.SurveyService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.HttpServletRequest;
import java.util.List;

@RestController
@RequestMapping("/api/survey")
public class SurveyController {

    private final SurveyService surveyService;

    @Autowired
    public SurveyController(SurveyService surveyService) {
        this.surveyService = surveyService;
    }

    /**
     * 根据token获取该用户创建的所有问卷。
     *
     * @param token 当前用户token。
     * @return json。
     */
    @GetMapping("/all")
    public SaResult listUserSurveys(@RequestParam(required = true) String token) {
        try {
            List<Survey> surveys = surveyService.getSurveysByToken(token);
            return SaResult.ok().setData(surveys);
        } catch (UserServiceException | DatabaseAccessException e) {
            return SaResult.error(e.getMessage());
        }
    }

    /**
     * 获取所有用户创建的所有问卷。
     *
     * @param token 管理员token。
     * @return json。
     */
    @GetMapping("/all-admin")
    public SaResult listAllSurveys(@RequestParam(required = true) String token) {
        try {
            List<Survey> surveys = surveyService.getAllSurveys(token);
            return SaResult.ok().setData(surveys);
        } catch (UserServiceException | DatabaseAccessException | SurveyServiceException e) {
            return SaResult.error(e.getMessage());
        }
    }

    @GetMapping("/filled")
    public SaResult listFilledSurveys(@RequestParam(required = true) String token) {
        List<Survey> surveys = null;
        try {
            surveys = surveyService.getFilledSurveys(token);
        } catch (BusinessException | DatabaseAccessException e) {
            return SaResult.error(e.getMessage());
        }
        return SaResult.ok().setData(surveys);
    }

    @RequestMapping(value = "/create", method = {RequestMethod.POST, RequestMethod.GET})
    public SaResult createSurvey(@RequestParam(required = true) String token) {
        try {
            return SaResult.ok("成功创建问卷。").setData(surveyService.createSurvey(token));
        } catch (UserServiceException | DatabaseAccessException e) {
            return SaResult.error(e.getMessage());
        }
    }

    @RequestMapping(value = "/{surveyId}", method = {RequestMethod.POST, RequestMethod.GET})
    public SaResult getSurvey(@PathVariable String surveyId, @RequestParam String token) {
        try {
            return SaResult.ok().setData(surveyService.accessSurvey(surveyId, token));
        } catch (SurveyServiceException | UserServiceException | DatabaseAccessException e) {
            return SaResult.error(e.getMessage());
        }
    }

    @RequestMapping(value = "/remove/{surveyId}", method = {RequestMethod.POST, RequestMethod.GET})
    public SaResult removeSurvey(@PathVariable String surveyId, @RequestParam String token) {
        try {
            surveyService.deleteSurvey(surveyId, token);
            return SaResult.ok("成功删除问卷。");
        } catch (SurveyServiceException | UserServiceException | DatabaseAccessException e) {
            return SaResult.error(e.getMessage());
        }
    }

    @RequestMapping(value = "/submit/{surveyId}", method = {RequestMethod.POST, RequestMethod.GET})
    public SaResult initSurvey(@PathVariable String surveyId, @RequestParam String token) {
        try {
            surveyService.submitSurvey(surveyId, token);
            return SaResult.ok("成功启用问卷。");
        } catch (SurveyServiceException | UserServiceException | DatabaseAccessException e) {
            return SaResult.error(e.getMessage());
        }
    }

    @RequestMapping(value = "/check/{surveyId}", method = {RequestMethod.POST, RequestMethod.GET})
    public SaResult checkSurvey(@PathVariable String surveyId, @RequestParam String token) {
        try {
            surveyService.checkSurvey(surveyId, token);
            return SaResult.ok("成功审核问卷。");
        } catch (SurveyServiceException | UserServiceException | DatabaseAccessException e) {
            return SaResult.error(e.getMessage());
        }
    }

    @RequestMapping(value = "/edit/{surveyId}", method = {RequestMethod.POST, RequestMethod.GET})
    public SaResult editSurvey(@PathVariable String surveyId, @RequestBody EditSurveyRequest req) {
        try {
            surveyService.editSurvey(surveyId, req.getTitle(), req.getDescription(), req.getStartTime(), req.getEndTime(), req.getToken());
            return SaResult.ok("成功编辑问卷。");
        } catch (SurveyServiceException | UserServiceException | DatabaseAccessException e) {
            return SaResult.error(e.getMessage());
        }
    }

    /**
     * 获取问卷分享链接。
     *
     * @param request  Servlet请求。
     * @param surveyId 问卷ID。
     * @param token    用户token。
     * @return json。
     */
    @RequestMapping(value = "/share/{surveyId}", method = {RequestMethod.GET, RequestMethod.POST})
    public SaResult shareSurvey(HttpServletRequest request, @PathVariable String surveyId, @RequestParam(required = true) String token) {

//            boolean canView = surveyService.canViewSurvey(surveyId, token);
//            if (!canView) {
//                return SaResult.error(String.format("不存在ID为 %s 的问卷，或者你没有它的访问权限。", surveyId));
//            }
        String url = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort() + request.getContextPath() + "/views/survey/survey_fill.jsp?surveyId=" + surveyId;
        return SaResult.ok().setData(url);
    }

}
