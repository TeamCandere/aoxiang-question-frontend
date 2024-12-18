package com.npu.aoxiangbackend.service;

import cn.dev33.satoken.stp.StpUtil;
import com.npu.aoxiangbackend.dao.IUserDao;
import com.npu.aoxiangbackend.exception.business.UserServiceException;
import com.npu.aoxiangbackend.exception.internal.DatabaseAccessException;
import com.npu.aoxiangbackend.exception.internal.InternalException;
import com.npu.aoxiangbackend.model.User;
import com.npu.aoxiangbackend.model.UserRole;
import com.npu.aoxiangbackend.protocol.RegisterRequest;
import com.npu.aoxiangbackend.util.ColoredPrintStream;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.web.bind.annotation.RequestParam;

import java.time.ZonedDateTime;
import java.util.Objects;
import java.util.Optional;
import java.util.List;

@Service
public class UserService {
    private final IUserDao userDao;
    private final ColoredPrintStream printer;

    @Autowired

    public UserService(IUserDao userDao, ColoredPrintStream coloredPrintStream) {
        this.userDao = userDao;
        this.printer = coloredPrintStream;
    }

    private void checkUsernameAndPasswordFormat(String username, String password) throws UserServiceException {
        if (username.length() < 4 || username.length() > 40) {
            throw new UserServiceException("用户名长度必须在4和40之间。");
        }

        if (password.length() < 6 || password.length() > 64) {
            throw new UserServiceException("密码长度必须在6和64之间。");
        }
    }

    public void throwOnInvalidRegister(String username, String password) throws UserServiceException, DatabaseAccessException {
        checkUsernameAndPasswordFormat(username, password);
        Optional<User> userOptional;

        try {
            userOptional = userDao.findUserByUsername(username);
        } catch (Exception exception) {
            throw new DatabaseAccessException();
        }
        if (userOptional.isPresent()) {
            throw new UserServiceException(String.format("用户名为\"%s\"的用户已经存在。", username));
        }
    }

    public void registerUser(RegisterRequest req) throws UserServiceException, DatabaseAccessException {
        var username = req.getUsername();
        var password = req.getPassword();

        throwOnInvalidRegister(username, password);

        User user = new User();
        user.setUsername(req.getUsername());
        user.setPassword(req.getPassword());
        user.setEmail(req.getEmail());
        user.setPhone(req.getPhone());
        user.setCreatedAt(ZonedDateTime.now());
        user.setUpdatedAt(ZonedDateTime.now());
        user.setRole(UserRole.Common);
        user.setDisplayName(req.getDisplayName());

        try {
            userDao.addUser(user);
        } catch (Exception e) {
            printer.shortPrintException(e);
            throw new DatabaseAccessException(e);
        }
    }

    public String loginUser(String userName, String password) throws InternalException, UserServiceException {
        Optional<User> userOptional;
        try {
            userOptional = userDao.findUserByUsername(userName);
        } catch (Exception e) {
            throw new DatabaseAccessException(e);
        }
        if (userOptional.isEmpty()) {
            throw new UserServiceException("用户不存在。");
        }
        var user = userOptional.get();
        if (!user.getPassword().equals(password)) {
            throw new UserServiceException("用户名或密码错误。");
        }
        try {
            StpUtil.createLoginSession(user.getId());
            return StpUtil.getTokenValueByLoginId(user.getId());
        } catch (Exception e) {
            throw new InternalException("未知错误。", e);
        }
    }

    public void logoutUser(String token) throws UserServiceException, InternalException {
        throwOnInvalidToken(token);
        try {
            StpUtil.logoutByTokenValue(token);
        } catch (Exception e) {
            printer.shortPrintException(e);
            throw new InternalException(e);
        }
    }

    public User getRequiredUser(String tokenValue) throws UserServiceException, DatabaseAccessException {
        long userId = checkAndGetUserId(tokenValue);
        return getRequiredUser(userId);
    }

    public User getRequiredUser(long userId) throws DatabaseAccessException, UserServiceException {
        Optional<User> userOptional;
        try {
            userOptional = userDao.findUserById(userId);
        } catch (Exception e) {
            printer.shortPrintException(e);
            throw new DatabaseAccessException(e);
        }
        if (userOptional.isEmpty())
            throw new UserServiceException(String.format("ID为 %d 的用户不存在。", userId));
        return userOptional.get();
    }

    /**
     * 尝试以指定登录状态获取用户ID为指定值的用户信息。
     *
     * @param userId     用户ID。
     * @param tokenValue 登录token。
     * @param selfOnly   是否仅允许用户本人登录访问。
     * @return 用户对象。
     * @throws DatabaseAccessException 如果数据库访问失败。
     * @throws UserServiceException    如果用户不存在。
     */
    public User getRequiredUserAndCheckLogin(long userId, String tokenValue, boolean selfOnly) throws DatabaseAccessException, UserServiceException {
        var currentUserId = checkAndGetUserId(tokenValue);
        var currentUser = getRequiredUser(currentUserId);

        if (selfOnly && currentUserId != userId && currentUser.getRole() != UserRole.Admin)
            throw new UserServiceException("你没有访问目标用户信息的权限。");

        return getRequiredUser(userId);
    }


    public void deleteUser(long userId, String tokenValue) throws UserServiceException, DatabaseAccessException {
        var currentUser = getRequiredUser(tokenValue);
        if (currentUser.getRole() != UserRole.Admin)
            throw new UserServiceException("只有管理员可以删除其他用户。");

        boolean deleted = false;
        try {
            deleted = userDao.deleteUser(userId);
        } catch (Exception e) {
            printer.shortPrintException(e);
            throw new DatabaseAccessException(e);
        }
        if (!deleted) {
            throw new UserServiceException("删除用户失败：用户不存在。");
        }
    }

    public List<User> getAllUsers(String tokenValue) throws UserServiceException, DatabaseAccessException {
        var currentUser = getRequiredUser(tokenValue);
        if (currentUser.getRole() != UserRole.Admin)
            throw new UserServiceException("只有管理员可以查看所有用户。");

        try {
            return userDao.getAllUsers();
        } catch (Exception e) {
            printer.shortPrintException(e);
            throw new DatabaseAccessException(e);
        }
    }

    public long getUserNum(String tokenValue) throws UserServiceException, DatabaseAccessException {
        var currentUser = getRequiredUser(tokenValue);
        if (currentUser.getRole() != UserRole.Admin)
            throw new UserServiceException("只有管理员可以查看所有用户。");

        try {
            return userDao.getUserCount();
        } catch (Exception e) {
            printer.shortPrintException(e);
            throw new DatabaseAccessException(e);
        }
    }

    /**
     * 根据token编译当前用户的信息。
     *
     * @param displayName 新的显示名称，为null则不做更改。
     * @param oldPassword 旧密码。
     * @param newPassword 新密码。
     * @param email       新的邮箱，为null则不做更改。
     * @param phoneNumber 新的手机号，为null则不做更改。
     * @param token       用户token。
     * @throws UserServiceException    如果token验证失败、密码不正确。
     * @throws DatabaseAccessException 如果数据库访问失败。
     */
    public void editUserProfile(String displayName, String oldPassword, String newPassword,
                                String email, String phoneNumber, String token) throws UserServiceException, DatabaseAccessException {
        var user = getRequiredUser(token);
        var username = user.getUsername();
        var password = user.getPassword();
        //验证用户名和密码格式
        checkUsernameAndPasswordFormat(username, password);

        if (!Objects.equals(user.getPassword(), oldPassword)) {
            throw new UserServiceException("用户的旧密码不正确。");
        }
        user.setPassword(newPassword);
        if (displayName != null)
            user.setDisplayName(displayName);
        if (email != null)
            user.setEmail(email);
        if (phoneNumber != null)
            user.setPhone(phoneNumber);

        try {
            userDao.updateUser(user);
        } catch (Exception e) {
            printer.shortPrintException(e);
            throw new DatabaseAccessException(e);
        }
    }

    public boolean isTokenValid(String token) {
        return StpUtil.getLoginIdByToken(token) != null;
    }

    public long checkAndGetUserId(String tokenValue) throws UserServiceException {
        var token = StpUtil.getLoginIdByToken(tokenValue);
        if (token == null)
            throw new UserServiceException("提供的token无效。");
        return Long.parseLong(token.toString());
    }

    public void throwOnInvalidToken(String tokenValue) throws UserServiceException {
        if (!isTokenValid(tokenValue)) {
            throw new UserServiceException("提供的token无效。");
        }
    }
}
