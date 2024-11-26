package com.npu.aoxiangbackend.service;

import com.npu.aoxiangbackend.dao.ISurveyDao;
import com.npu.aoxiangbackend.exception.business.SurveyServiceException;
import com.npu.aoxiangbackend.exception.business.UserServiceException;
import com.npu.aoxiangbackend.exception.internal.DatabaseAccessException;
import com.npu.aoxiangbackend.model.Survey;
import com.npu.aoxiangbackend.model.UserRole;
import com.npu.aoxiangbackend.util.ColoredPrintStream;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.ZonedDateTime;
import java.util.List;
import java.util.Optional;

@Service
public class SurveyService {

    private final ISurveyDao surveyDao; // 问卷数据访问对象
    private final UserService userService; // 用户服务对象
    private final ColoredPrintStream printer; // 用于打印带颜色的日志信息

    @Autowired
    public SurveyService(ISurveyDao surveyDao, UserService userService, ColoredPrintStream printer) {
        this.surveyDao = surveyDao; // 注入问卷数据访问对象
        this.userService = userService; // 注入用户服务对象
        this.printer = printer; // 注入彩色打印工具
    }

    /**
     * 使用用户token获取该用户创建的所有问卷。
     *
     * @param tokenValue 用户token值。
     * @return 该用户名下的所有问卷对象。
     * @throws UserServiceException    当token校验失败时抛出。
     * @throws DatabaseAccessException 当数据库访问失败时抛出。
     */
    public List<Survey> getSurveysByToken(String tokenValue) throws UserServiceException, DatabaseAccessException {
        var userId = userService.checkAndGetUserId(tokenValue); // 验证token并获取用户ID
        try {
            return surveyDao.findSurveysByUserId(userId); // 根据用户ID查找问卷
        } catch (Exception e) {
            printer.shortPrintException(e); // 打印异常信息
            throw new DatabaseAccessException(e); // 数据库访问异常
        }
    }

    /**
     * 使用指定用户token在该用户名下创建一个问卷。
     *
     * @param tokenValue 用户token值。
     * @return 新创建的问卷的uuid。
     * @throws UserServiceException    当token校验失败时抛出。
     * @throws DatabaseAccessException 当数据库访问失败时抛出。
     */
    public String createSurvey(String tokenValue) throws UserServiceException, DatabaseAccessException {
        var userId = userService.checkAndGetUserId(tokenValue); // 验证token并获取用户ID

        Survey survey = new Survey();
        survey.setCreatorId(userId); // 设置创建者ID
        survey.setSubmitted(false); // 问卷未提交
        survey.setChecked(false); // 问卷未审核
        survey.setCheckerId(null); // 无审核者
        survey.setLoginRequired(false); // 不需要登录
        survey.setPublic(false); // 问卷不公开
        survey.setTitle("新建问卷"); // 默认标题
        survey.setDescription("新建问卷"); // 默认描述
        survey.setTotalResponses(0); // 总响应数为0
        survey.setCreatedAt(ZonedDateTime.now()); // 创建时间
        survey.setUpdatedAt(ZonedDateTime.now()); // 更新时间
        survey.setStartTime(ZonedDateTime.now()); // 开始时间
        survey.setEndTime(ZonedDateTime.now().plusDays(1)); // 结束时间（默认1天后）

        try {
            return surveyDao.addSurvey(survey); // 添加问卷到数据库
        } catch (Exception e) {
            printer.shortPrintException(e); // 打印异常信息
            throw new DatabaseAccessException(e); // 数据库访问异常
        }
    }

    /**
     * 尝试使用指定登录状态访问某个问卷。
     *
     * @param surveyId   目标问卷ID。
     * @param tokenValue 登录用户的token值。（如果问卷不需要登录且公开，该值被忽略）
     * @return 问卷对象。
     * @throws DatabaseAccessException 如果数据库访问错误。
     * @throws SurveyServiceException  如果问卷不存在，或当前没有访问权限。
     * @throws UserServiceException    如果需要登录验证，且提供的token无效。
     */
    public Survey accessSurvey(String surveyId, String tokenValue) throws DatabaseAccessException, SurveyServiceException, UserServiceException {
        Survey survey = getRequiredSurvey(surveyId); // 获取问卷对象

        boolean submitted = survey.isSubmitted(); // 问卷是否已提交
        boolean checked = survey.isChecked(); // 问卷是否已审核
        boolean loginRequired = survey.isLoginRequired(); // 问卷是否需要登录
        boolean isPublic = survey.isPublic(); // 问卷是否公开

        // 问卷已审核、不需要登录且公开，直接放行
        if (checked && !loginRequired && isPublic)
            return survey;

        // 验证是否登录
        var user = userService.getRequiredUser(tokenValue); // 获取当前登录用户

        // 对于管理员和创建者，直接放行
        if (user.getRole() == UserRole.Admin || user.getId() == survey.getCreatorId()) {
            return survey;
        }

        // 对于其他用户，该问卷必须通过审核且公开
        if (!checked)
            throw new SurveyServiceException("该问卷暂未通过审核。"); // 问卷未审核
        if (!isPublic)
            throw new SurveyServiceException("该问卷由其他用户创建，且暂未公开。"); // 问卷不公开

        return survey;
    }

    /**
     * 根据surveyId从数据库获取Survey对象，这个方法会在未找到时抛出异常。
     *
     * @param surveyId Survey标识符
     * @return 问卷对象
     * @throws DatabaseAccessException 如果数据库访问失败
     * @throws SurveyServiceException  如果问卷不存在
     */
    public Survey getRequiredSurvey(String surveyId) throws DatabaseAccessException, SurveyServiceException {
        Optional<Survey> surveyOptional;
        try {
            surveyOptional = surveyDao.findSurveyById(surveyId); // 根据ID查找问卷
        } catch (Exception e) {
            printer.shortPrintException(e); // 打印异常信息
            throw new DatabaseAccessException(e); // 数据库访问异常
        }

        if (surveyOptional.isEmpty()) {
            throw new SurveyServiceException(String.format("该问卷不存在：%s", surveyId)); // 问卷不存在
        }
        return surveyOptional.get(); // 返回问卷对象
    }

    /**
     * 根据登录状态和问卷ID获取问卷对象，并检查是否为创建者或管理员。
     *
     * @param surveyId    问卷ID
     * @param tokenValue  登录token
     * @param creatorOnly 是否仅限创建者访问
     * @return 问卷对象
     * @throws DatabaseAccessException 如果数据库访问失败
     * @throws SurveyServiceException  如果问卷不存在或当前用户没有访问权限
     * @throws UserServiceException    如果登录状态无效
     */
    private Survey getRequiredSurveyAndCheckLogin(String surveyId, String tokenValue, boolean creatorOnly) throws DatabaseAccessException, SurveyServiceException, UserServiceException {
        var user = userService.getRequiredUser(tokenValue); // 获取当前登录用户
        Survey survey = getRequiredSurvey(surveyId); // 获取问卷对象

        // 检查是否为管理员或创建者
        if (user.getRole() != UserRole.Admin && creatorOnly && survey.getCreatorId() != user.getId())
            throw new SurveyServiceException("当前用户不是该问卷的创建者，也不是管理人员。"); // 无权限访问

        return survey;
    }

    /**
     * 尝试以指定登录状态删除问卷。
     *
     * @param surveyId   问卷标识符。
     * @param tokenValue 登录Token。
     * @throws DatabaseAccessException 如果数据库访问失败。
     * @throws SurveyServiceException  如果当前用户没有删除权限。
     * @throws UserServiceException    如果登录状态无效。
     */
    public void deleteSurvey(String surveyId, String tokenValue) throws DatabaseAccessException, SurveyServiceException, UserServiceException {
        getRequiredSurveyAndCheckLogin(surveyId, tokenValue, true); // 检查权限
        try {
            surveyDao.deleteSurvey(surveyId); // 删除问卷
        } catch (Exception e) {
            printer.shortPrintException(e); // 打印异常信息
            throw new DatabaseAccessException(e); // 数据库访问异常
        }
    }

    /**
     * 更新问卷信息。
     *
     * @param surveyId      问卷ID
     * @param tokenValue    登录token
     * @param loginRequired 是否需要登录
     * @param isPublic      是否公开
     * @param title         问卷标题
     * @param description   问卷描述
     * @param startTime     问卷开始时间
     * @param endTime       问卷结束时间
     * @throws SurveyServiceException  如果当前用户没有操作权限。
     * @throws DatabaseAccessException 如果数据库访问失败。
     * @throws UserServiceException    如果登录状态无效。
     */
    public void updateSurvey(String surveyId, String tokenValue, boolean loginRequired, boolean isPublic,
                             String title, String description, ZonedDateTime startTime, ZonedDateTime endTime) throws SurveyServiceException, DatabaseAccessException, UserServiceException {
        var survey = getRequiredSurveyAndCheckLogin(surveyId, tokenValue, true); // 检查权限
        survey.setLoginRequired(loginRequired);
        survey.setPublic(isPublic);
        survey.setTitle(title);
        survey.setDescription(description);
        survey.setStartTime(startTime);
        survey.setEndTime(endTime);

        try {
            surveyDao.updateSurvey(survey); // 更新问卷信息
        } catch (Exception e) {
            printer.shortPrintException(e); // 打印异常信息
            throw new DatabaseAccessException(e); // 数据库访问异常
        }
    }

    /**
     * 以指定登录状态尝试提交一个问卷。问卷只有在被提交且审核通过后才能开始填写。
     *
     * @param surveyId   问卷ID。
     * @param tokenValue 登录token。
     * @throws DatabaseAccessException 如果数据库访问失败。
     * @throws SurveyServiceException  如果当前用户没有操作权限。
     * @throws UserServiceException    如果登录状态无效。
     */
    public void submitSurvey(String surveyId, String tokenValue) throws DatabaseAccessException, SurveyServiceException, UserServiceException {
        var survey = getRequiredSurveyAndCheckLogin(surveyId, tokenValue, true); // 检查权限
        if (!survey.isSubmitted()) {
            survey.setSubmitted(true); // 设置问卷为已提交
        } else {
            throw new SurveyServiceException("该问卷已经提交。"); // 问卷已提交
        }

        try {
            surveyDao.updateSurvey(survey); // 更新问卷信息
        } catch (Exception e) {
            printer.shortPrintException(e); // 打印异常信息
            throw new DatabaseAccessException(e); // 数据库访问异常
        }
    }

    /**
     * 以指定登录状态（必须为管理员）尝试审核一个问卷，
     *
     * @param surveyId   问卷ID。
     * @param tokenValue 登录token。
     * @throws DatabaseAccessException 如果数据库访问失败。
     * @throws SurveyServiceException  如果当前用户没有操作权限。
     * @throws UserServiceException    如果登录状态无效。
     */
    public void checkSurvey(String surveyId, String tokenValue) throws DatabaseAccessException, SurveyServiceException, UserServiceException {
        var user = userService.getRequiredUser(tokenValue); // 获取当前登录用户
        if (user.getRole() != UserRole.Admin)
            throw new SurveyServiceException("当前用户不是管理员，无法审核问卷。"); // 无权限审核

        var survey = getRequiredSurvey(surveyId);
        if (!survey.isSubmitted()) {
            throw new SurveyServiceException("该问卷尚未提交。"); // 问卷未提交
        }
        if (survey.isChecked()) {
            throw new SurveyServiceException("该问卷已经审核。"); // 问卷已审核
        }
        survey.setChecked(true); // 设置问卷为已审核
        survey.setCheckerId(user.getId()); // 设置审核者ID
        try {
            surveyDao.updateSurvey(survey); // 更新问卷信息
        } catch (Exception e) {
            printer.shortPrintException(e); // 打印异常信息
            throw new DatabaseAccessException(e); // 数据库访问异常
        }
    }

    /**
     * 检查当前用户是否有权限查看问卷。
     *
     * @param surveyId   问卷ID
     * @param tokenValue 登录token
     * @return 是否有权限查看问卷
     * @throws DatabaseAccessException 如果数据库访问失败
     */
    public boolean canViewSurvey(String surveyId, String tokenValue) throws DatabaseAccessException {
        try {
            accessSurvey(surveyId, tokenValue); // 尝试访问问卷
            return true; // 有权限查看
        } catch (SurveyServiceException | UserServiceException e) {
            return false; // 无权限查看
        }
    }

    /**
     * 检查当前用户是否有权限编辑问卷。
     *
     * @param surveyId   问卷ID
     * @param tokenValue 登录token
     * @return 是否有权限编辑问卷
     * @throws DatabaseAccessException 如果数据库访问失败
     */
    public boolean canEditSurvey(String surveyId, String tokenValue) throws DatabaseAccessException {
        try {
            getRequiredSurveyAndCheckLogin(surveyId, tokenValue, true); // 尝试获取问卷并检查权限
            return true; // 有权限编辑
        } catch (SurveyServiceException | UserServiceException e) {
            return false; // 无权限编辑
        }
    }

    public long getTotalSurveys() throws DatabaseAccessException {
        try {
            return surveyDao.getTotalSurveys();
        } catch (Exception e) {
            printer.shortPrintException(e);
            throw new DatabaseAccessException(e);
        }
    }

    public long getApprovedSurveys() throws DatabaseAccessException {
        try {
            return surveyDao.getApprovedSurveys();
        } catch (Exception e) {
            printer.shortPrintException(e);
            throw new DatabaseAccessException(e);
        }
    }

    /**
     * 根据token获取该用户所填写过的所有问卷。
     *
     * @param token 用户token。
     * @return 填写过的问卷对象列表。
     */
    public List<Survey> getFilledSurveys(String token) throws SurveyServiceException {
        throw new SurveyServiceException("暂未实现");
    }
}