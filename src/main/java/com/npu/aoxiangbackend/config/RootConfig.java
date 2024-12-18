package com.npu.aoxiangbackend.config;

import org.springframework.context.annotation.ComponentScan;
import org.springframework.context.annotation.ComponentScan.Filter;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.FilterType;
import org.springframework.context.annotation.Import;
import org.springframework.web.servlet.config.annotation.EnableWebMvc;


/**
 * 配置类，用于管理ContextLoadListener创建的上下文的bean
 */
// 定义为配置类
@Configuration
// 引入数据库配置类
@Import({BeanConfig.class, WebConfig.class})
@EnableWebMvc
// 定义Spring 扫描的包名，采用自定义扫描类WebPackage
@ComponentScan(basePackages = {"com.npu.aoxiangbackend"})
public class RootConfig {
}
