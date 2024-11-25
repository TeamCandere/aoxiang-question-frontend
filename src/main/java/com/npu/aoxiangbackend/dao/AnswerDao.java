package com.npu.aoxiangbackend.dao;

import com.npu.aoxiangbackend.model.Answer;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository // 标记为Spring管理的Repository组件
public class AnswerDao implements IAnswerDao {

    private final SessionFactory sessionFactory; // 注入SessionFactory用于创建Session

    @Autowired // 自动注入SessionFactory
    public AnswerDao(SessionFactory sessionFactory) {
        this.sessionFactory = sessionFactory; // 构造器注入SessionFactory
    }

    @Override
    public Optional<Answer> findAnswerById(long id) {
        try (Session session = sessionFactory.openSession()) { // 打开一个新的Session
            session.beginTransaction(); // 开始事务
            Answer answer = session.get(Answer.class, id); // 根据ID查找Answer对象
            session.getTransaction().commit(); // 提交事务
            return Optional.ofNullable(answer); // 返回可能为空的结果
        }
    }

    @Override
    public List<Answer> findAnswersByResponseId(String responseId) {
        try (Session session = sessionFactory.openSession()) { // 打开一个新的Session
            session.beginTransaction(); // 开始事务
            var query = session.createQuery("from Answer where responseId = :responseId", Answer.class); // 创建查询
            query.setParameter("responseId", responseId); // 设置查询参数
            var answers = query.getResultList(); // 获取结果列表
            session.getTransaction().commit(); // 提交事务
            return answers; // 返回结果列表
        }
    }

    @Override
    public List<Answer> findAnswersByQuestionId(long questionId) {
        try (Session session = sessionFactory.openSession()) { // 打开一个新的Session
            session.beginTransaction(); // 开始事务
            var query = session.createQuery("from Answer where questionId = :questionId", Answer.class); // 创建查询
            query.setParameter("questionId", questionId); // 设置查询参数
            var answers = query.getResultList(); // 获取结果列表
            session.getTransaction().commit(); // 提交事务
            return answers; // 返回结果列表
        }
    }

    public Optional<Answer> findAnswerByResponseIdAndQuestionId(String responseId, long questionId) {
        try (Session session = sessionFactory.openSession()) { // 打开一个新的Session
            session.beginTransaction(); // 开始事务
            var query = session.createQuery("from Answer where questionId = :questionId and responseId = :responseId", Answer.class); // 创建查询
            query.setParameter("questionId", questionId); // 设置查询参数
            query.setParameter("responseId", responseId); // 设置查询参数
            var answer = query.uniqueResultOptional(); // 获取结果列表
            session.getTransaction().commit(); // 提交事务
            return answer;
        }
    }

    @Override
    public long addAnswer(Answer answer) {
        try (Session session = sessionFactory.openSession()) { // 打开一个新的Session
            session.beginTransaction(); // 开始事务
            long answerId = (long) session.save(answer); // 保存新的Answer对象并获取生成的ID
            session.getTransaction().commit(); // 提交事务
            return answerId; // 返回新生成的ID
        }
    }

    @Override
    public boolean updateAnswer(Answer answer) {
        try (Session session = sessionFactory.openSession()) { // 打开一个新的Session
            session.beginTransaction(); // 开始事务
            session.update(answer); // 更新已存在的Answer对象
            session.getTransaction().commit(); // 提交事务
            return true; // 返回成功标志
        }
    }

    @Override
    public boolean deleteAnswer(long id) {
        try (Session session = sessionFactory.openSession()) { // 打开一个新的Session
            session.beginTransaction(); // 开始事务
            Answer answer = session.get(Answer.class, id); // 根据ID查找Answer对象
            if (answer != null) { // 如果对象存在
                session.delete(answer); // 删除对象
                session.getTransaction().commit(); // 提交事务
                return true; // 返回成功标志
            } else {
                session.getTransaction().commit(); // 如果对象不存在，仍然提交事务
                return false; // 返回失败标志
            }
        }
    }
}