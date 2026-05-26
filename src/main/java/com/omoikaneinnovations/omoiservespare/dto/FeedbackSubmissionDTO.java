package com.omoikaneinnovations.omoiservespare.dto;

import jakarta.validation.constraints.*;

/**
 * DTO for feedback submission from users
 */
public class FeedbackSubmissionDTO {
    
    @NotNull(message = "Rating is required")
    @Min(value = 1, message = "Rating must be at least 1")
    @Max(value = 5, message = "Rating must be at most 5")
    private Integer rating;
    
    @NotBlank(message = "Comments are required")
    @Size(max = 2000, message = "Comments must not exceed 2000 characters")
    private String comments;
    
    // Constructors
    public FeedbackSubmissionDTO() {}
    
    public FeedbackSubmissionDTO(Integer rating, String comments) {
        this.rating = rating;
        this.comments = comments;
    }
    
    // Getters and Setters
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
}
