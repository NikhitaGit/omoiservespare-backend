package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.domain.FeedbackStatus;
import com.omoikaneinnovations.omoiservespare.dto.FeedbackDTO;
import com.omoikaneinnovations.omoiservespare.dto.FeedbackSubmissionDTO;
import com.omoikaneinnovations.omoiservespare.entity.Feedback;
import com.omoikaneinnovations.omoiservespare.entity.User;
import com.omoikaneinnovations.omoiservespare.repository.FeedbackRepository;
import com.omoikaneinnovations.omoiservespare.repository.UserRepository;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDateTime;

@Service
public class FeedbackService {
    
    private static final Logger log = LoggerFactory.getLogger(FeedbackService.class);
    
    @Autowired
    private FeedbackRepository feedbackRepository;
    
    @Autowired
    private UserRepository userRepository;
    
    /**
     * Submit new feedback
     */
    @Transactional
    public FeedbackDTO submitFeedback(FeedbackSubmissionDTO dto, String userEmail) {
        log.info("Submitting feedback from user: {}", userEmail);
        
        // Look up user
        User user = userRepository.findByEmail(userEmail)
            .orElseThrow(() -> new RuntimeException("User not found: " + userEmail));
        
        // Sanitize input (trim whitespace)
        String sanitizedComments = dto.getComments().trim();
        
        // Create feedback entity
        Feedback feedback = new Feedback(user, user.getCompanyName(), dto.getRating(), sanitizedComments);
        
        // Save to database
        Feedback saved = feedbackRepository.save(feedback);
        
        log.info("Feedback submitted: id={}, userId={}, companyName={}, rating={}", 
            saved.getId(), user.getId(), user.getCompanyName(), dto.getRating());
        
        return toDTO(saved);
    }
    
    /**
     * Get feedback for company with optional status filter and pagination
     */
    @Transactional(readOnly = true)
    public Page<FeedbackDTO> getFeedbackForCompany(String companyName, FeedbackStatus status, 
                                                    int page, int size) {
        log.info("Fetching feedback for company: {}, status: {}, page: {}, size: {}", 
            companyName, status, page, size);
        
        Pageable pageable = PageRequest.of(page, size);
        Page<Feedback> feedbackPage;
        
        if (status == null) {
            feedbackPage = feedbackRepository.findByCompanyNameOrderByCreatedAtDesc(companyName, pageable);
        } else {
            feedbackPage = feedbackRepository.findByCompanyNameAndStatusOrderByCreatedAtDesc(
                companyName, status, pageable);
        }
        
        return feedbackPage.map(this::toDTO);
    }
    
    /**
     * Mark feedback as reviewed
     */
    @Transactional
    public FeedbackDTO markAsReviewed(Long feedbackId, String adminEmail) {
        log.info("Marking feedback as reviewed: id={}, adminEmail={}", feedbackId, adminEmail);
        
        Feedback feedback = feedbackRepository.findById(feedbackId)
            .orElseThrow(() -> new RuntimeException("Feedback not found: " + feedbackId));
        
        // Verify admin is from same company
        User admin = userRepository.findByEmail(adminEmail)
            .orElseThrow(() -> new RuntimeException("Admin user not found: " + adminEmail));
        
        if (!feedback.getCompanyName().equals(admin.getCompanyName())) {
            throw new RuntimeException("Cannot review feedback from another company");
        }
        
        // Update status
        feedback.setStatus(FeedbackStatus.REVIEWED);
        feedback.setReviewedAt(LocalDateTime.now());
        
        Feedback updated = feedbackRepository.save(feedback);
        
        log.info("Feedback marked as reviewed: id={}, reviewedAt={}", updated.getId(), updated.getReviewedAt());
        
        return toDTO(updated);
    }
    
    /**
     * Get feedback count for company
     */
    @Transactional(readOnly = true)
    public long getFeedbackCount(String companyName) {
        return feedbackRepository.countByCompanyName(companyName);
    }
    
    /**
     * Convert entity to DTO
     */
    private FeedbackDTO toDTO(Feedback feedback) {
        return new FeedbackDTO(
            feedback.getId(),
            feedback.getUser().getEmail(),
            feedback.getCompanyName(),
            feedback.getRating(),
            feedback.getComments(),
            feedback.getStatus(),
            feedback.getCreatedAt(),
            feedback.getReviewedAt()
        );
    }
}
