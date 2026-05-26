package com.omoikaneinnovations.omoiservespare.controller;

import com.omoikaneinnovations.omoiservespare.domain.AccountType;
import com.omoikaneinnovations.omoiservespare.domain.FeedbackStatus;
import com.omoikaneinnovations.omoiservespare.dto.FeedbackDTO;
import com.omoikaneinnovations.omoiservespare.dto.FeedbackSubmissionDTO;
import com.omoikaneinnovations.omoiservespare.entity.User;
import com.omoikaneinnovations.omoiservespare.repository.UserRepository;
import com.omoikaneinnovations.omoiservespare.service.ExportService;
import com.omoikaneinnovations.omoiservespare.service.FeedbackService;
import jakarta.validation.Valid;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.Authentication;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@RestController
@RequestMapping("/api/feedback")
@CrossOrigin(origins = {"http://localhost:5173", "http://localhost:5174"})
public class FeedbackController {
    
    private static final Logger log = LoggerFactory.getLogger(FeedbackController.class);
    
    @Autowired
    private FeedbackService feedbackService;
    
    @Autowired
    private ExportService exportService;
    
    @Autowired
    private UserRepository userRepository;
    
    /**
     * Submit feedback (authenticated users)
     */
    @PostMapping
    public ResponseEntity<FeedbackDTO> submitFeedback(
            @Valid @RequestBody FeedbackSubmissionDTO dto,
            Authentication auth) {
        
        String userEmail = auth.getName();
        log.info("Feedback submission request from: {}", userEmail);
        
        FeedbackDTO feedback = feedbackService.submitFeedback(dto, userEmail);
        return ResponseEntity.status(HttpStatus.CREATED).body(feedback);
    }
    
    /**
     * Get feedback list (PROFESSIONAL only)
     */
    @GetMapping
    public ResponseEntity<Page<FeedbackDTO>> getFeedback(
            @RequestParam(required = false) FeedbackStatus status,
            @RequestParam(defaultValue = "0") int page,
            @RequestParam(defaultValue = "20") int size,
            Authentication auth) {
        
        String userEmail = auth.getName();
        log.info("Feedback retrieval request from: {}, status: {}, page: {}, size: {}", 
            userEmail, status, page, size);
        
        // Check if user is PROFESSIONAL
        User user = userRepository.findByEmail(userEmail)
            .orElseThrow(() -> new RuntimeException("User not found"));
        
        if (user.getAccountType() != AccountType.PROFESSIONAL) {
            log.warn("Access denied: user {} is not PROFESSIONAL", userEmail);
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        
        Page<FeedbackDTO> feedbackPage = feedbackService.getFeedbackForCompany(
            user.getCompanyName(), status, page, size);
        
        return ResponseEntity.ok(feedbackPage);
    }
    
    /**
     * Mark feedback as reviewed (PROFESSIONAL only)
     */
    @PutMapping("/{id}/review")
    public ResponseEntity<FeedbackDTO> markAsReviewed(
            @PathVariable Long id,
            Authentication auth) {
        
        String userEmail = auth.getName();
        log.info("Mark as reviewed request from: {}, feedbackId: {}", userEmail, id);
        
        // Check if user is PROFESSIONAL
        User user = userRepository.findByEmail(userEmail)
            .orElseThrow(() -> new RuntimeException("User not found"));
        
        if (user.getAccountType() != AccountType.PROFESSIONAL) {
            log.warn("Access denied: user {} is not PROFESSIONAL", userEmail);
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        
        FeedbackDTO feedback = feedbackService.markAsReviewed(id, userEmail);
        return ResponseEntity.ok(feedback);
    }
    
    /**
     * Export feedback to CSV (PROFESSIONAL only)
     */
    @GetMapping("/export/csv")
    public ResponseEntity<byte[]> exportCSV(Authentication auth) {
        String userEmail = auth.getName();
        log.info("CSV export request from: {}", userEmail);
        
        // Check if user is PROFESSIONAL
        User user = userRepository.findByEmail(userEmail)
            .orElseThrow(() -> new RuntimeException("User not found"));
        
        if (user.getAccountType() != AccountType.PROFESSIONAL) {
            log.warn("Access denied: user {} is not PROFESSIONAL", userEmail);
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        
        // Get all feedback for company
        Page<FeedbackDTO> feedbackPage = feedbackService.getFeedbackForCompany(
            user.getCompanyName(), null, 0, Integer.MAX_VALUE);
        List<FeedbackDTO> feedbackList = feedbackPage.getContent();
        
        // Generate CSV
        byte[] csvData = exportService.exportToCSV(feedbackList);
        
        // Generate filename with timestamp
        String filename = "feedback_" + user.getCompanyName() + "_" + 
            LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss")) + ".csv";
        
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.parseMediaType("text/csv"));
        headers.setContentDispositionFormData("attachment", filename);
        
        log.info("CSV export completed: {} records, filename: {}", feedbackList.size(), filename);
        
        return ResponseEntity.ok()
            .headers(headers)
            .body(csvData);
    }
    
    /**
     * Export feedback to Excel (PROFESSIONAL only)
     */
    @GetMapping("/export/excel")
    public ResponseEntity<byte[]> exportExcel(Authentication auth) {
        String userEmail = auth.getName();
        log.info("Excel export request from: {}", userEmail);
        
        // Check if user is PROFESSIONAL
        User user = userRepository.findByEmail(userEmail)
            .orElseThrow(() -> new RuntimeException("User not found"));
        
        if (user.getAccountType() != AccountType.PROFESSIONAL) {
            log.warn("Access denied: user {} is not PROFESSIONAL", userEmail);
            return ResponseEntity.status(HttpStatus.FORBIDDEN).build();
        }
        
        // Get all feedback for company
        Page<FeedbackDTO> feedbackPage = feedbackService.getFeedbackForCompany(
            user.getCompanyName(), null, 0, Integer.MAX_VALUE);
        List<FeedbackDTO> feedbackList = feedbackPage.getContent();
        
        // Generate Excel
        byte[] excelData = exportService.exportToExcel(feedbackList);
        
        // Generate filename with timestamp
        String filename = "feedback_" + user.getCompanyName() + "_" + 
            LocalDateTime.now().format(DateTimeFormatter.ofPattern("yyyyMMdd_HHmmss")) + ".xlsx";
        
        HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.parseMediaType(
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"));
        headers.setContentDispositionFormData("attachment", filename);
        
        log.info("Excel export completed: {} records, filename: {}", feedbackList.size(), filename);
        
        return ResponseEntity.ok()
            .headers(headers)
            .body(excelData);
    }
}
