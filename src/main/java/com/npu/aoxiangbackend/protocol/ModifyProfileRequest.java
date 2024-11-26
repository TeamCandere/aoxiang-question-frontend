package com.npu.aoxiangbackend.protocol;

import lombok.Data;

@Data
public class ModifyProfileRequest {
    String displayName;
    String email;
    String phone;
    String oldPassword;
    String newPassword;
}
