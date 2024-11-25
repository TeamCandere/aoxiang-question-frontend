package com.npu.aoxiangbackend.service;

import com.npu.aoxiangbackend.dao.IResponseDao;
import com.npu.aoxiangbackend.exception.business.BusinessException;
import com.npu.aoxiangbackend.exception.business.ResponseServiceException;
import com.npu.aoxiangbackend.exception.business.SurveyServiceException;
import com.npu.aoxiangbackend.exception.business.UserServiceException;
import com.npu.aoxiangbackend.exception.internal.DatabaseAccessException;
import com.npu.aoxiangbackend.model.Response;
import com.npu.aoxiangbackend.model.Survey;
import com.npu.aoxiangbackend.model.User;
import com.npu.aoxiangbackend.model.UserRole;
import com.npu.aoxiangbackend.util.ColoredPrintStream;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class ResponseService {

    private final IResponseDao responseDao;
    private final SurveyService surveyService;
    private final UserService userService;
    private final ColoredPrintStream printer;

    @Autowired
    public ResponseService(IResponseDao responseDao, SurveyService surveyService, UserService userService, ColoredPrintStream printer) {
        this.responseDao = responseDao;
        this.surveyService = surveyService;
        this.userService = userService;
        this.printer = printer;
    }

    /**
     * 使用用户token获取该用户的所有响应。
     *
     * @param tokenValue 用户token值。
     * @return 该用户的响应列表。
     * @throws UserServiceException    当token校验失败时抛出。
     * @throws DatabaseAccessException 当数据库访问失败时抛出。
     */
    public List<Response> getResponsesByToken(String tokenValue) throws UserServiceException, DatabaseAccessException {
        var userId = userService.checkAndGetUserId(tokenValue);
        try {
            return responseDao.findResponsesByUserId(userId);
        } catch (Exception e) {
            printer.shortPrintException(e);
            throw new DatabaseAccessException(e);
        }
    }

    /**
     * 通过用户ID和问卷ID获取该用户在指定问卷下填写的答卷。
     *
     * @param userId   用户ID。
     * @param surveyId 问卷ID。
     * @return 答卷。
     * @throws DatabaseAccessException  当数据库访问失败时抛出。
     * @throws ResponseServiceException 当符合条件的答卷不存在时抛出。
     */
    public Response getResponsesByUserIdAndSurveyId(long userId, String surveyId) throws DatabaseAccessException, ResponseServiceException {

        Optional<Response> response;
        try {
            response = responseDao.findResponseBySurveyIdAndUserId(surveyId, userId);
        } catch (Exception e) {
            printer.shortPrintException(e);
            throw new DatabaseAccessException(e);
        }

        if (response.isEmpty())
            throw new ResponseServiceException("不存在符合条件的答卷。");

        return response.get();
    }

    /**
     * 使用指定用户token为某个调查添加一个响应。
     *
     * @param surveyId   调查ID。
     * @param tokenValue 用户token值。
     * @return 新创建的响应的uuid。
     * @throws UserServiceException    当token校验失败时抛出。
     * @throws DatabaseAccessException 当数据库访问失败时抛出。
     */
    public String addResponse(String surveyId, String tokenValue) throws UserServiceException, DatabaseAccessException {
        if (tokenValue == null || tokenValue.isBlank()) {

        }
        var userId = userService.checkAndGetUserId(tokenValue);

        Response response = new Response();
        response.setSurveyId(surveyId);
        response.setUserId(userId);
        response.setSubmittedAt(ZonedDateTime.now());

        try {
            return responseDao.addResponse(response);
        } catch (Exception e) {
            printer.shortPrintException(e);
            throw new DatabaseAccessException(e);
        }
    }

    /**
     * 删除指定ID的响应对象。
     *
     * @param responseId 响应ID。
     * @param tokenValue 用户token值。
     * @throws UserServiceException    当token校验失败时抛出。
     * @throws DatabaseAccessException 当数据库访问失败时抛出。
     */
    public void deleteResponse(String responseId, String tokenValue) throws UserServiceException, DatabaseAccessException {
        var userId = userService.checkAndGetUserId(tokenValue);

        Optional<Response> responseOptional;
        try {
            responseOptional = responseDao.findResponseById(responseId);
        } catch (Exception e) {
            printer.shortPrintException(e);
            throw new DatabaseAccessException(e);
        }

        if (responseOptional.isEmpty()) {
            throw new RuntimeException("响应不存在");
        }

        Response response = responseOptional.get();
        if (response.getUserId() != userId) {
            throw new RuntimeException("当前用户无权删除此响应");
        }

        try {
            responseDao.deleteResponse(responseId);
        } catch (Exception e) {
            printer.shortPrintException(e);
            throw new DatabaseAccessException(e);
        }
    }

    /**
     * 获取指定ID的响应对象。
     *
     * @param responseId 响应ID。
     * @param tokenValue 用户token值。
     * @return 响应对象。
     * @throws UserServiceException    当token校验失败时抛出。
     * @throws DatabaseAccessException 当数据库访问失败时抛出。
     */
    public Response accessResponseById(String responseId, String tokenValue) throws BusinessException, DatabaseAccessException {
        var user = userService.getRequiredUser(tokenValue);

        Optional<Response> responseOptional;
        try {
            responseOptional = responseDao.findResponseById(responseId);
        } catch (Exception e) {
            printer.shortPrintException(e);
            throw new DatabaseAccessException(e);
        }

        if (responseOptional.isEmpty()) {
            throw new ResponseServiceException("答卷不存在。");
        }

        Response response = responseOptional.get();
        Survey survey = surveyService.getRequiredSurvey(response.getSurveyId());

        if (response.getUserId() != user.getId() && user.getId() != survey.getCreatorId() && user.getRole() != UserRole.Admin) {
            throw new ResponseServiceException("只有答卷填写者、问卷创建者和管理员能够查看此答卷。");
        }

        return response;
    }

    public Response getRequiredResponse(String responseId) throws DatabaseAccessException, ResponseServiceException {
        Optional<Response> responseOptional;
        try {
            responseOptional = responseDao.findResponseById(responseId);
        } catch (Exception e) {
            printer.shortPrintException(e);
            throw new DatabaseAccessException(e);
        }
        if (responseOptional.isEmpty()) {
            throw new ResponseServiceException("不存在ID为 " + responseId + " 的答卷。");
        }
        return responseOptional.get();
    }

    /**
     * 检查用户是否有权限查看某个响应。
     *
     * @param responseId 响应ID。
     * @param tokenValue 用户token值。
     * @return 用户是否有权限查看该响应。
     */
    public boolean canViewResponse(String responseId, String tokenValue) throws DatabaseAccessException {
        try {
            accessResponseById(responseId, tokenValue);
            return true;
        } catch (BusinessException ex) {
            return false;
        }
    }
}