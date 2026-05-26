package com.omoikaneinnovations.omoiservespare.dto;

import com.omoikaneinnovations.omoiservespare.domain.FeedbackStatus;
import java.time.LocalDateTime;

/**
 * DTO for feedback responses to clients
 */
public class FeedbackDTO {
    
    private Long id;
    private String userEmail;
    private String companyName;
    private Integer rating;
    private String comments;
    private FeedbackStatus status;
    private LocalDateTime createdAt;
    private LocalDateTime reviewedAt;
    
    // Constructors
    public FeedbackDTO() {}
    
    public FeedbackDTO(Long id, String userEmail, String companyName, Integer rating, 
                      String comments, FeedbackStatus status, LocalDateTime createdAt, 
                      LocalDateTime reviewedAt) {
        this.id = id;
        this.userEmail = userEmail;
        this.companyName = companyName;
        this.rating = rating;
        this.comments = comments;
        this.status = status;
        this.createdAt = createdAt;
        this.reviewedAt = reviewedAt;
    }
    
    // Getters and Setters
    public Long getId() {
        return id;
    }
    
    public void setId(Long id) {
        this.id = id;
    }
    
    public String getUserEmail() {
        return userEmail;
    }
    
    public void setUserEmail(String userEmail) {
        this.userEmail = userEmail;
    }
    
    public String getCompanyName() {
        return companyName;
    }
    
    public void setCompanyName(String companyName) {
        this.companyName = companyName;
    }
    
    public Integer getRating() {
        return rating;
    }
    
    public void setRating(Integer rating) {
        this.rating = rating;
    }
    
    public String getComments() {
        return comments;
    }
    
    public void setComments(String comments) {
        this.comments = comments;
    }
    
    public FeedbackStatus getStatus() {
        return status;
    }
    
    public void setStatus(FeedbackStatus status) {
        this.status = status;
    }
    
    public LocalDateTime getCreatedAt() {
        return createdAt;
    }
    
    public void setCreatedAt(LocalDateTime createdAt) {
        this.createdAt = createdAt;
    }
    
    public LocalDateTime getReviewedAt() {
        return reviewedAt;
    }
    
    public void setReviewedAt(LocalDateTime reviewedAt) {
        this.reviewedAt = reviewedAt;
    }
}
