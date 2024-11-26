package com.npu.aoxiangbackend.dao;

import com.npu.aoxiangbackend.model.Survey;
import org.hibernate.Session;
import org.hibernate.SessionFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public class SurveyDao implements ISurveyDao {
    private final SessionFactory sessionFactory;

    @Autowired
    public SurveyDao(SessionFactory sessionFactory) {
        this.sessionFactory = sessionFactory;
    }

    @Override
    public Optional<Survey> findSurveyById(String id) {
        try (Session session = sessionFactory.openSession()) {
            session.beginTransaction();
            Survey survey = session.get(Survey.class, id);
            session.getTransaction().commit();
            return Optional.ofNullable(survey);
        }
    }

    @Override
    public Optional<Survey> findSurveyByTitle(String title) {
        try (Session session = sessionFactory.openSession()) {
            session.beginTransaction();
            var query = session.createQuery("from Survey where title = :title", Survey.class);
            query.setParameter("title", title);
            var survey = query.uniqueResultOptional();
            session.getTransaction().commit();
            return survey;
        }
    }

    @Override
    public List<Survey> findSurveysByUserId(long userId) {
        try (Session session = sessionFactory.openSession()) {
            session.beginTransaction();
            var query = session.createQuery("from Survey where creatorId = :userId", Survey.class);
            query.setParameter("userId", userId);
            var surveys = query.getResultList();
            session.getTransaction().commit();
            return surveys;
        }
    }

    @Override
    public String addSurvey(Survey survey) {
        try (Session session = sessionFactory.openSession()) {
            session.beginTransaction();
            String surveyId = (String) session.save(survey);
            session.getTransaction().commit();
            return surveyId;
        }
    }

    @Override
    public boolean updateSurvey(Survey survey) {
        try (Session session = sessionFactory.openSession()) {
            session.beginTransaction();
            session.update(survey);
            session.getTransaction().commit();
            return true;
        }
    }

    @Override
    public boolean deleteSurvey(String id) {
        try (Session session = sessionFactory.openSession()) {
            session.beginTransaction();
            Survey survey = session.get(Survey.class, id);
            if (survey != null) {
                session.delete(survey);
                session.getTransaction().commit();
                return true;
            } else {
                session.getTransaction().commit();
                return false;
            }
        }
    }

    public long getTotalSurveys() {
        try (Session session = sessionFactory.openSession()) {
            session.beginTransaction();
            var query = session.createQuery("select count(*) from Survey", Long.class);
            return query.getSingleResult();
        }
    }

    public long getApprovedSurveys() {
        try (Session session = sessionFactory.openSession()) {
            session.beginTransaction();
            var query = session.createQuery("select count(*) from Survey where isChecked = :checked", Long.class);
            query.setParameter("checked", true);
            return query.getSingleResult();
        }
    }

    @Override
    public List<Survey> getFilledSurveys(long userId) {
        try (Session session = sessionFactory.openSession()) {
            session.beginTransaction();
            var query = session.createQuery(" from Survey where id in (select surveyId from Response where userId = :userId)", Survey.class);
            query.setParameter("userId", userId);
            return query.list();
        }
    }

    @Override
    public List<Survey> listAllSurveys() {
        try (Session session = sessionFactory.openSession()) {
            session.beginTransaction();
            var query = session.createQuery(" from Survey", Survey.class);
            return query.list();
        }
    }
}