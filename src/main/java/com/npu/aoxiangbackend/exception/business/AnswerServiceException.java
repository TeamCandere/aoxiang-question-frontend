package com.npu.aoxiangbackend.exception.business;

public class AnswerServiceException extends BusinessException{
    public AnswerServiceException(String message) {
        super(message);
    }

    public AnswerServiceException(String message, Throwable cause) {
        super(message, cause);
    }
}
