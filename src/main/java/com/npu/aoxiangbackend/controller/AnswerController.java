package com.npu.aoxiangbackend.controller;

import cn.dev33.satoken.util.SaResult;
import com.npu.aoxiangbackend.exception.business.BusinessException;
import com.npu.aoxiangbackend.exception.business.QuestionServiceException;
import com.npu.aoxiangbackend.exception.internal.DatabaseAccessException;
import com.npu.aoxiangbackend.service.AnswerService;
import com.npu.aoxiangbackend.service.QuestionService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/answer")
public class AnswerController {
    private final AnswerService answerService;

    @Autowired
    public AnswerController(AnswerService answerService) {
        this.answerService = answerService;
    }

    @RequestMapping("/all")
    public SaResult enumerateAnswers(@RequestParam(required = true) long questionId, @RequestParam(required = false) String token) {
        try {
            return SaResult.ok("成功获取问题下的所有回答。").setData(answerService.getAnswersByQuestionId(questionId, token));
        } catch (BusinessException | DatabaseAccessException e) {
            return SaResult.error(e.getMessage());
        }
    }

    @RequestMapping(value = "/fill", method = {RequestMethod.GET, RequestMethod.POST})
    public SaResult addOrModifyAnswer(@RequestParam(required = true) long questionId, @RequestParam(required = true) String responseId, @RequestParam(required = true) String content, @RequestParam(required = true) String token) {
        try {
            return SaResult.ok("成功添加回答。").setData(answerService.fillAnswer(responseId, questionId, content, token));
        } catch (BusinessException | DatabaseAccessException e) {
            return SaResult.error(e.getMessage());
        }
    }

    @RequestMapping(value = "/{answerId}", method = {RequestMethod.GET, RequestMethod.POST})
    public SaResult getAnswer(@PathVariable(name = "answerId") long answerId, @RequestParam(required = false) String token) {
        try {
            return SaResult.ok("成功查询回答。").setData(answerService.accessAnswer(answerId, token));
        } catch (BusinessException | DatabaseAccessException e) {
            return SaResult.error(e.getMessage());
        }
    }
}
