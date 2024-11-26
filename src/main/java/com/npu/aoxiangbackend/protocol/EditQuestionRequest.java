package com.npu.aoxiangbackend.protocol;

import lombok.Data;

@Data
public class EditQuestionRequest {
    private String content;
    private String token;
    private long questionId;
}
