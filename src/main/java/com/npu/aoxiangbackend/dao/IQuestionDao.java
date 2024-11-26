package com.npu.aoxiangbackend.dao;

import com.npu.aoxiangbackend.model.Question;

import java.util.List;
import java.util.Optional;

public interface IQuestionDao {
    long addQuestion(Question question);

    Optional<Question> findQuestionById(long id);

    int getQuestionCountOfSurvey(String surveyID);

    List<Question> findQuestionsBySurveyId(String surveyId);

    List<Question> findUnfilledQuestionsByResponseId(String responseId);

    boolean deleteQuestion(long id);

    boolean updateQuestion(Question question);
}
