package com.npu.aoxiangbackend.protocol;

import lombok.Data;

import java.time.ZonedDateTime;

@Data
public class EditSurveyRequest {
    private String title;
    private String description;
    private String token;
    private ZonedDateTime startTime;
    private ZonedDateTime endTime;
}
