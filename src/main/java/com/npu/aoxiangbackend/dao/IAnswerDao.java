package com.npu.aoxiangbackend.dao;

import com.npu.aoxiangbackend.model.Answer;

import java.util.List;
import java.util.Optional;

public interface IAnswerDao {

    /**
     * 根据ID查找Answer对象。
     *
     * @param id 答案的ID。
     * @return 可能为空的Answer对象。
     */
    Optional<Answer> findAnswerById(long id);

    /**
     * 根据responseId查找所有Answer对象。
     *
     * @param responseId 响应的ID。
     * @return Answer对象列表。
     */
    List<Answer> findAnswersByResponseId(String responseId);

    List<Answer> findAnswersByQuestionId(long questionId);

    Optional<Answer> findAnswerByResponseIdAndQuestionId(String responseId, long questionId);

    /**
     * 添加新的答案对象。
     *
     * @param answer 答案对象。
     * @return 答案的uuid。
     */
    long addAnswer(Answer answer);

    /**
     * 更新指定的答案对象。
     *
     * @param answer 答案对象。
     * @return 操作是否成功。
     */
    boolean updateAnswer(Answer answer);

    /**
     * 删除指定ID的答案对象。
     *
     * @param id 答案的ID。
     * @return 操作是否成功。
     */
    boolean deleteAnswer(long id);
}