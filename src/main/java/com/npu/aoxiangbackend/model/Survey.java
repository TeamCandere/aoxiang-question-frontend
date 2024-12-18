package com.npu.aoxiangbackend.model;

import lombok.Data;
import org.hibernate.annotations.GenericGenerator;

import javax.persistence.*;

import java.time.ZonedDateTime;

@Data
@Entity
@Table(name = "surveys")
public class Survey {
    @Id
    @GeneratedValue(generator = "idGenerator")
    @GenericGenerator(name = "idGenerator", strategy = "uuid")
    private String id;

    @Column(nullable = false)
    private String title;
    private String description;

    @Column(nullable = false)
    private long creatorId;

    @Column(nullable = false)
    private boolean isPublic;

    @Column(nullable = false)
    private boolean isSubmitted;

    @Column(nullable = false)
    private ZonedDateTime startTime;

    @Column(nullable = false)
    private ZonedDateTime endTime;

    @Column(nullable = false)
    private boolean loginRequired;

    @Column(nullable = false)
    private boolean isChecked;

    private Long checkerId;

    @Column(nullable = false)
    private int totalResponses;

    @Column(nullable = false)
    private ZonedDateTime createdAt;

    @Column(nullable = false)
    private ZonedDateTime updatedAt;
}