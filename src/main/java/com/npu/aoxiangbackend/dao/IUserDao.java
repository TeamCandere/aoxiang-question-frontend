package com.npu.aoxiangbackend.dao;

import com.npu.aoxiangbackend.model.User;

import java.util.Optional;
import java.util.List;

public interface IUserDao {
    public Optional<User> findUserById(long id);

    public Optional<User> findUserByEmail(String email);

    public Optional<User> findUserByUsername(String username);

    public boolean addUser(User user);

    public boolean updateUser(User user);

    public boolean deleteUser(long id);

    List<User> getAllUsers();
}
