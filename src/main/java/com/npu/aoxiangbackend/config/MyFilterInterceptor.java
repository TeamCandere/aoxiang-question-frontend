package com.npu.aoxiangbackend.config;

import cn.dev33.satoken.stp.StpUtil;
import org.springframework.web.servlet.HandlerInterceptor;
import org.springframework.web.servlet.ModelAndView;
import org.springframework.web.servlet.handler.HandlerInterceptorAdapter;

import javax.interceptor.Interceptor;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

/**
 * 拦截器，用于拦截非授权请求。
 */
public class MyFilterInterceptor implements HandlerInterceptor {

    /**
     * 拦截未登录的请求。
     * @param request 请求对象。
     * @param response 响应对象。
     * @param handler 处理器。
     * @return 如果要拦截则返回false，否则返回true。
     */
    public boolean preHandle(HttpServletRequest request, HttpServletResponse response, Object handler) {
        var token = request.getParameter("token");
        var loginId = (Long) StpUtil.getLoginIdByToken(token);

        //如果获取不到LoginId，则未登录，拦截请求。
        return loginId == null || loginId.longValue() == 0;
    }

    public void postHandle(HttpServletRequest request, HttpServletResponse response, Object handler, ModelAndView modelAndView) {
    }

    public void afterCompletion(HttpServletRequest request, HttpServletResponse response, Object handler, Exception ex) {
    }
}
