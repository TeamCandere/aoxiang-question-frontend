package com.npu.aoxiangbackend.controller;

import cn.dev33.satoken.util.SaResult;
import com.npu.aoxiangbackend.exception.business.BusinessException;
import com.npu.aoxiangbackend.exception.business.UserServiceException;
import com.npu.aoxiangbackend.exception.internal.DatabaseAccessException;
import com.npu.aoxiangbackend.model.Response;
import com.npu.aoxiangbackend.service.ResponseService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/response")
public class ResponseController {

    private final ResponseService responseService;

    @Autowired
    public ResponseController(ResponseService responseService) {
        this.responseService = responseService;
    }

    @GetMapping("/all")
    public SaResult listUserResponses(@RequestParam(required = true) String token) {
        try {
            List<Response> responses = responseService.getResponsesByToken(token);
            return SaResult.ok().setData(responses);
        } catch (UserServiceException | DatabaseAccessException e) {
            return SaResult.error(e.getMessage());
        }
    }

    @RequestMapping(value = "/create", method = {RequestMethod.GET, RequestMethod.POST})
    public SaResult createResponse(@RequestParam(required = true) String surveyId, @RequestParam(required = true) String token) {
        try {
            String responseId = responseService.addResponse(surveyId, token);
            return SaResult.ok("成功创建答卷。").setData(responseId);
        } catch (UserServiceException | DatabaseAccessException e) {
            return SaResult.error(e.getMessage());
        }
    }

    @RequestMapping(value = "/{responseId}", method = {RequestMethod.GET, RequestMethod.POST})
    public SaResult getResponse(@PathVariable String responseId, @RequestParam String token) {
        try {
            Response response = responseService.accessResponseById(responseId, token);
            return SaResult.ok().setData(response);
        } catch (BusinessException | DatabaseAccessException e) {
            return SaResult.error(e.getMessage());
        }
    }

    @PostMapping("/delete/{responseId}")
    public SaResult deleteResponse(@PathVariable String responseId, @RequestParam String token) {
        try {
            responseService.deleteResponse(responseId, token);
            return SaResult.ok("成功删除答卷。");
        } catch (BusinessException | DatabaseAccessException e) {
            return SaResult.error(e.getMessage());
        }
    }

    @RequestMapping(value = "/submit/{responseId}", method = {RequestMethod.GET, RequestMethod.POST})
    public SaResult submitResponse(@PathVariable String responseId, @RequestParam(required = true) String token) {
        try {
            responseService.submitResponse(responseId, token);
            return SaResult.ok("成功提交答卷。");
        } catch (BusinessException | DatabaseAccessException e) {
            return SaResult.error(e.getMessage());
        }
    }
}