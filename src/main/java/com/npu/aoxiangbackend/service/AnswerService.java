package com.npu.aoxiangbackend.service;

import com.npu.aoxiangbackend.dao.IAnswerDao;
import com.npu.aoxiangbackend.exception.business.*;
import com.npu.aoxiangbackend.exception.internal.DatabaseAccessException;
import com.npu.aoxiangbackend.model.Answer;
import com.npu.aoxiangbackend.model.Response;
import com.npu.aoxiangbackend.model.UserRole;
import com.npu.aoxiangbackend.util.ColoredPrintStream;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class AnswerService {

    private final IAnswerDao answerDao;
    private final ResponseService responseService;
    private final QuestionService questionService;
    private final UserService userService;
    private final ColoredPrintStream printer;
    private final SurveyService surveyService;

    @Autowired
    public AnswerService(IAnswerDao answerDao, ResponseService responseService, QuestionService questionService, UserService userService, ColoredPrintStream printer, SurveyService surveyService) {
        this.answerDao = answerDao;
        this.responseService = responseService;
        this.questionService = questionService;
        this.userService = userService;
        this.printer = printer;
        this.surveyService = surveyService;
    }

    /**
     * 使用用户token和问卷ID获取该用户对某个问卷的答卷下的所有回答。
     *
     * @param tokenValue 用户token值。
     * @param surveyId   问卷ID。
     * @return 该用户对问卷的所有答卷列表。
     * @throws UserServiceException     当token校验失败时抛出。
     * @throws DatabaseAccessException  当数据库访问失败时抛出。
     * @throws ResponseServiceException 当给定问卷不存在或问卷不由该用户创建时抛出。
     */
    public List<Answer> getAnswersBySurveyId(String tokenValue, String surveyId) throws UserServiceException, DatabaseAccessException, ResponseServiceException {
        var userId = userService.checkAndGetUserId(tokenValue);
        Response response = responseService.getResponsesByUserIdAndSurveyId(userId, surveyId);
        try {
            return answerDao.findAnswersByResponseId(response.getId());
        } catch (Exception e) {
            printer.shortPrintException(e);
            throw new DatabaseAccessException(e);
        }
    }

    public List<Answer> getAnswersByQuestionId(long questionId, String tokenValue) throws UserServiceException, QuestionServiceException, DatabaseAccessException, SurveyServiceException, AnswerServiceException {
        var user = userService.getRequiredUser(tokenValue);
        var question = questionService.getRequiredQuestion(questionId);
        var survey = surveyService.getRequiredSurvey(question.getSourceSurveyId());
        if (user.getRole() != UserRole.Admin && user.getId() != survey.getCreatorId()) {
            throw new AnswerServiceException("只有管理员和问卷创建者能够查看某个问题的所有回答。");
        }
        return answerDao.findAnswersByQuestionId(questionId);
    }

    /**
     * 使用指定用户token在某个问卷的答复中添加一个答案。
     *
     * @param tokenValue 用户token值。
     * @param responseId 答卷ID。
     * @param questionId 题目ID。
     * @param content    答案内容。
     * @return 新创建的答案的ID。
     * @throws DatabaseAccessException 当数据库访问失败时抛出。
     */
    public long fillAnswer(String responseId, long questionId, String content, String tokenValue) throws DatabaseAccessException, BusinessException {
        var userId = userService.checkAndGetUserId(tokenValue);
        var response = responseService.getRequiredResponse(responseId);

        if (!questionService.canViewQuestion(questionId, tokenValue))
            throw new AnswerServiceException("你没有访问指定问题的权限。");

        Optional<Answer> answerOptional;
        try {
            answerOptional = answerDao.findAnswerByResponseIdAndQuestionId(responseId, questionId);
        } catch (Exception e) {
            printer.shortPrintException(e);
            throw new DatabaseAccessException(e);
        }

        //如果之前已经有过回答，则在原先回答基础上修改。
        if (answerOptional.isPresent()) {
            Answer answer = answerOptional.get();
            answer.setContent(content);
            answerDao.updateAnswer(answer);
            return answer.getId();
        }

        Answer answer = new Answer();
        answer.setResponseId(response.getId());
        answer.setQuestionId(questionId);
        answer.setContent(content);
        answer.setCreatedAt(ZonedDateTime.now());

        try {
            return answerDao.addAnswer(answer);
        } catch (Exception e) {
            printer.shortPrintException(e);
            throw new DatabaseAccessException(e);
        }
    }

    /**
     * 根据答案ID从数据库获取Answer对象，这个方法会在未找到时抛出异常。
     *
     * @param answerId 答案ID
     * @return 答案对象
     * @throws DatabaseAccessException 如果数据库访问失败
     * @throws AnswerServiceException  如果答案不存在
     */
    public Answer getRequiredAnswer(long answerId) throws DatabaseAccessException, AnswerServiceException {
        Optional<Answer> answerOptional;
        try {
            answerOptional = answerDao.findAnswerById(answerId);
        } catch (Exception e) {
            printer.shortPrintException(e);
            throw new DatabaseAccessException(e);
        }

        if (answerOptional.isEmpty()) {
            throw new AnswerServiceException(String.format("该答卷不存在：%s", answerId));
        }
        return answerOptional.get();
    }

    public Answer accessAnswer(long answerId, String tokenValue) throws DatabaseAccessException, AnswerServiceException, UserServiceException {
        var userId = userService.checkAndGetUserId(tokenValue);
        var answer = getRequiredAnswer(answerId);
        if (!responseService.canViewResponse(answer.getResponseId(), tokenValue)) {
            throw new AnswerServiceException("你没有访问该回答所属答卷的权限。");
        }
        return answer;
    }

    /**
     * 检查当前用户是否有权限查看答卷。
     *
     * @param tokenValue 用户token值。
     * @param answerId   答案ID。
     * @return 是否有权限查看答案
     * @throws DatabaseAccessException 如果数据库访问失败
     */
    public boolean canViewAnswer(String tokenValue, long answerId) throws DatabaseAccessException {
        try {
            var answer = getRequiredAnswer(answerId);
            return responseService.canViewResponse(answer.getResponseId(), tokenValue);
        } catch (AnswerServiceException e) {
            return false;
        }
    }

    /**
     * 检查当前用户是否有权限编辑答案。
     *
     * @param tokenValue 用户token值。
     * @param answerId   答案ID。
     * @return 是否有权限编辑答案
     * @throws DatabaseAccessException 如果数据库访问失败
     */
    public boolean canEditAnswer(String tokenValue, long answerId) throws DatabaseAccessException, ResponseServiceException {
        try {
            var userId = userService.checkAndGetUserId(tokenValue);
            var answer = getRequiredAnswer(answerId);
            var response = responseService.getRequiredResponse(answer.getResponseId());

            return response.getUserId() == userId;
        } catch (UserServiceException | AnswerServiceException e) {
            return false;
        }
    }
}