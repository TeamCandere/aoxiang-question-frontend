package com.npu.aoxiangbackend.exception.business;

public class ResponseServiceException extends BusinessException{
    public ResponseServiceException(String message) {
        super(message);
    }

    public ResponseServiceException(String message, Throwable cause) {
        super(message, cause);
    }
}
