package com.npu.aoxiangbackend.service;

import com.npu.aoxiangbackend.dao.IResponseDao;
import com.npu.aoxiangbackend.exception.business.BusinessException;
import com.npu.aoxiangbackend.exception.business.ResponseServiceException;
import com.npu.aoxiangbackend.exception.business.UserServiceException;
import com.npu.aoxiangbackend.exception.internal.DatabaseAccessException;
import com.npu.aoxiangbackend.model.Question;
import com.npu.aoxiangbackend.model.Response;
import com.npu.aoxiangbackend.model.Survey;
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
    private final QuestionService questionService;

    @Autowired
    public ResponseService(IResponseDao responseDao, SurveyService surveyService, UserService userService, ColoredPrintStream printer, QuestionService questionService) {
        this.responseDao = responseDao;
        this.surveyService = surveyService;
        this.userService = userService;
        this.printer = printer;
        this.questionService = questionService;
    }

    /**
     * 使用用户token获取该用户的所有答卷。
     *
     * @param tokenValue 用户token值。
     * @return 该用户的答卷列表。
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
     * 使用指定token尝试提交一个答卷。
     *
     * @param responseId 答卷ID。
     * @param tokenValue 用户token。
     * @throws ResponseServiceException 如果非用户本人操作或必填问题未填写。
     * @throws DatabaseAccessException  如果数据库访问错误。
     * @throws UserServiceException     如果token无效。
     */
    public void submitResponse(String responseId, String tokenValue) throws ResponseServiceException, DatabaseAccessException, UserServiceException {
        var response = getRequiredResponse(responseId);
        var user = userService.getRequiredUser(tokenValue);
        if (response.getUserId() != user.getId()) {
            throw new ResponseServiceException("只有用户本人才能提交答卷。");
        }

        if (questionService.getUnfilledQuestionsByResponseId(responseId).stream().anyMatch(Question::isRequired)) {
            throw new ResponseServiceException("存在必填问题没有填写。");
        }
        response.setSubmitted(true);
        response.setSubmittedAt(ZonedDateTime.now());
        responseDao.updateResponse(response);
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
    public List<Response> getResponsesByUserIdAndSurveyId(long userId, String surveyId) throws DatabaseAccessException, ResponseServiceException {

        List<Response> responses;
        try {
            responses = responseDao.findResponsesBySurveyIdAndUserId(surveyId, userId);
        } catch (Exception e) {
            printer.shortPrintException(e);
            throw new DatabaseAccessException(e);
        }

        return responses;
    }

    /**
     * 使用指定用户token为该用户在指定问卷下添加一个答卷。
     *
     * @param surveyId   调查ID。
     * @param tokenValue 用户token值。
     * @return 新创建的响应的uuid。
     * @throws UserServiceException    当token校验失败时抛出。
     * @throws DatabaseAccessException 当数据库访问失败时抛出。
     */
    public String addResponse(String surveyId, String tokenValue) throws UserServiceException, DatabaseAccessException {
        var userId = userService.checkAndGetUserId(tokenValue);

        Response response = new Response();
        response.setSurveyId(surveyId);
        response.setUserId(userId);
        response.setSubmitted(false);
        response.setSubmittedAt(null);

        try {
            return responseDao.addResponse(response);
        } catch (Exception e) {
            printer.shortPrintException(e);
            throw new DatabaseAccessException(e);
        }
    }

    /**
     * 删除指定ID的响应对象。该方法会进行删除权限检测。
     * 删除前提：登录用户为管理员 或 登录用户为填写者且问卷尚未提交。
     *
     * @param responseId 响应ID。
     * @param tokenValue 用户token值。
     * @throws UserServiceException    当token校验失败时抛出。
     * @throws DatabaseAccessException 当数据库访问失败时抛出。
     */
    public void deleteResponse(String responseId, String tokenValue) throws UserServiceException, DatabaseAccessException, ResponseServiceException {
        var user = userService.getRequiredUser(tokenValue);

        Optional<Response> responseOptional;
        try {
            responseOptional = responseDao.findResponseById(responseId);
        } catch (Exception e) {
            printer.shortPrintException(e);
            throw new DatabaseAccessException(e);
        }

        if (responseOptional.isEmpty()) {
            throw new ResponseServiceException(String.format("用户 %s 下不存在ID为 %s 的答卷。", user.getDisplayName(), responseId));
        }

        Response response = responseOptional.get();
        if (user.getRole() != UserRole.Admin && (user.getId() != response.getUserId() || response.isSubmitted())) {
            throw new ResponseServiceException(String.format("用户 %s 当前没有删除答卷的权限。只有答卷填写者在提交问卷前能够删除答卷。", user.getDisplayName()));
        }

        try {
            responseDao.deleteResponse(responseId);
        } catch (Exception e) {
            printer.shortPrintException(e);
            throw new DatabaseAccessException(e);
        }
    }

    /**
     * 尝试根据指定ID访问答卷对象。该方法会进行查看权限检测。
     *
     * @param responseId 答卷ID。
     * @param tokenValue 用户token值。
     * @return 答卷对象。
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

    /**
     * 根据答卷ID获取答卷。在答卷不存在时抛出异常。
     *
     * @param responseId 答卷ID。
     * @return 答卷对象。
     * @throws DatabaseAccessException  如果数据库访问失败。
     * @throws ResponseServiceException 如果答卷不存在。
     */
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
     * 检查用户是否有权限查看某个答卷。
     *
     * @param responseId 答卷ID。
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