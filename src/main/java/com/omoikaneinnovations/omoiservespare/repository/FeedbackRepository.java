package com.omoikaneinnovations.omoiservespare.repository;

import com.omoikaneinnovations.omoiservespare.domain.FeedbackStatus;
import com.omoikaneinnovations.omoiservespare.entity.Feedback;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface FeedbackRepository extends JpaRepository<Feedback, Long> {
    
    // Find all feedback for a specific company, ordered by creation date (newest first)
    List<Feedback> findByCompanyNameOrderByCreatedAtDesc(String companyName);
    
    // Find feedback by company and status, ordered by creation date
    List<Feedback> findByCompanyNameAndStatusOrderByCreatedAtDesc(
        String companyName, 
        FeedbackStatus status
    );
    
    // Count feedback by company
    long countByCompanyName(String companyName);
    
    // Paginated queries
    Page<Feedback> findByCompanyNameOrderByCreatedAtDesc(String companyName, Pageable pageable);
    
    Page<Feedback> findByCompanyNameAndStatusOrderByCreatedAtDesc(
        String companyName, 
        FeedbackStatus status, 
        Pageable pageable
    );
}
