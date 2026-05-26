# Implementation Plan: Company Feedback System

## Overview

This implementation plan breaks down the company feedback system into discrete, incremental coding tasks. Each task builds on previous work, with testing integrated throughout to catch errors early. The plan follows a bottom-up approach: database → entities → repositories → services → controllers → frontend integration.

## Tasks

- [ ] 1. Add Apache Commons CSV dependency and create database migration
  - Add Apache Commons CSV dependency to pom.xml (version 1.10.0)
  - Create Flyway migration V7__create_feedback_table.sql with feedback table, indexes, and constraints
  - Verify migration runs successfully
  - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 11.6_

- [ ] 2. Create domain enums and DTOs
  - [ ] 2.1 Create FeedbackStatus enum (NEW, REVIEWED)
    - Create enum in domain package
    - _Requirements: 4.1, 4.3_
  
  - [ ] 2.2 Create FeedbackSubmissionDTO with validation annotations
    - Add @NotNull, @Min, @Max for rating
    - Add @NotBlank, @Size for comments
    - _Requirements: 1.1, 1.2, 9.2_
  
  - [ ] 2.3 Create FeedbackDTO for responses
    - Include all fields: id, userEmail, companyName, rating, comments, status, createdAt, reviewedAt
    - _Requirements: 8.5, 18_

- [ ] 3. Create Feedback entity and repository
  - [ ] 3.1 Create Feedback entity class
    - Add JPA annotations (@Entity, @Table, @Id, @GeneratedValue)
    - Add relationship to User entity (@ManyToOne)
    - Add all fields with appropriate constraints
    - Add @PrePersist to set createdAt and default status
    - _Requirements: 1.3, 1.4, 11.1, 11.6_
  
  - [ ] 3.2 Create FeedbackRepository interface
    - Extend JpaRepository<Feedback, Long>
    - Add query methods: findByCompanyNameOrderByCreatedAtDesc, findByCompanyNameAndStatusOrderByCreatedAtDesc
    - Add paginated methods: findByCompanyName, findByCompanyNameAndStatus
    - Add count method: countByCompanyName
    - _Requirements: 2.1, 4.4, 8.1, 8.2_
  
  - [ ]* 3.3 Write property test for default status
    - **Property 3: Valid Feedback Persistence**
    - **Validates: Requirements 1.3, 1.5, 11.6**
    - Test that creating feedback without explicit status defaults to NEW

- [ ] 4. Implement FeedbackService
  - [ ] 4.1 Create FeedbackService interface and implementation
    - Implement submitFeedback method with user lookup and validation
    - Implement getFeedbackForCompany with pagination and filtering
    - Implement markAsReviewed with authorization check
    - Implement getFeedbackCount method
    - Add input sanitization (trim whitespace, prevent XSS)
    - _Requirements: 1.3, 1.4, 2.1, 2.4, 4.1, 4.2, 8.1, 8.2, 9.1, 9.4_
  
  - [ ]* 4.2 Write property test for multi-tenant isolation
    - **Property 6: Multi-Tenant Data Isolation**
    - **Validates: Requirements 2.1**
    - Create feedback for multiple companies, verify queries return only matching company data
  
  - [ ]* 4.3 Write property test for automatic metadata capture
    - **Property 4: Automatic Metadata Capture**
    - **Validates: Requirements 1.4, 2.4**
    - Submit feedback and verify email, company name, and timestamp are populated
  
  - [ ]* 4.4 Write property test for status transition
    - **Property 9: Status Transition to REVIEWED**
    - **Validates: Requirements 4.1, 4.2**
    - Mark feedback as reviewed and verify status changes and reviewedAt is set
  
  - [ ]* 4.5 Write property test for whitespace trimming
    - **Property 21: Whitespace Trimming**
    - **Validates: Requirements 9.4**
    - Submit comments with leading/trailing whitespace and verify it's trimmed

- [ ] 5. Implement ExportService
  - [ ] 5.1 Create ExportService interface and implementation
    - Implement exportToCSV using Apache Commons CSV
    - Implement exportToExcel using Apache POI
    - Include all required columns in both formats
    - Format Excel with bold headers and appropriate column widths
    - _Requirements: 5.1, 5.2, 6.1, 6.2, 6.3_
  
  - [ ]* 5.2 Write property test for CSV export completeness
    - **Property 13: CSV Column Completeness**
    - **Validates: Requirements 5.2**
    - Generate CSV and verify all required columns are present
  
  - [ ]* 5.3 Write property test for Excel export completeness
    - **Property 15: Excel Column Completeness**
    - **Validates: Requirements 6.2**
    - Generate Excel and verify all required columns are present
  
  - [ ]* 5.4 Write property test for CSV multi-tenancy
    - **Property 12: CSV Export Multi-Tenancy**
    - **Validates: Requirements 5.1**
    - Create feedback for multiple companies, export as one company, verify only that company's data
  
  - [ ]* 5.5 Write property test for Excel multi-tenancy
    - **Property 14: Excel Export Multi-Tenancy**
    - **Validates: Requirements 6.1**
    - Create feedback for multiple companies, export as one company, verify only that company's data

- [ ] 6. Checkpoint - Ensure service layer tests pass
  - Run all service layer tests
  - Verify multi-tenancy, validation, and export functionality
  - Ask the user if questions arise

- [ ] 7. Create FeedbackController
  - [ ] 7.1 Implement FeedbackController with all endpoints
    - POST /api/feedback - submit feedback (authenticated users)
    - GET /api/feedback - get feedback list (PROFESSIONAL only)
    - PUT /api/feedback/{id}/review - mark as reviewed (PROFESSIONAL only)
    - GET /api/feedback/export/csv - export CSV (PROFESSIONAL only)
    - GET /api/feedback/export/excel - export Excel (PROFESSIONAL only)
    - Add @Valid for request body validation
    - Extract user context from Authentication object
    - Check accountType for admin endpoints
    - _Requirements: 1.5, 1.6, 3.1, 3.2, 3.4, 4.3, 4.4, 5.4, 6.5, 8.1, 8.2, 8.3, 8.4, 8.5_
  
  - [ ]* 7.2 Write property test for rating validation
    - **Property 1: Rating Validation Range**
    - **Validates: Requirements 1.1**
    - Submit feedback with ratings outside 1-5 and verify rejection
  
  - [ ]* 7.3 Write property test for comments validation
    - **Property 2: Comments Length Validation**
    - **Validates: Requirements 1.2**
    - Submit feedback with empty comments and comments >2000 chars, verify rejection
  
  - [ ]* 7.4 Write property test for validation error messages
    - **Property 5: Validation Error Messages**
    - **Validates: Requirements 1.6**
    - Submit invalid feedback and verify descriptive error messages
  
  - [ ]* 7.5 Write property test for PROFESSIONAL access control
    - **Property 7: PROFESSIONAL Access Control**
    - **Validates: Requirements 3.1**
    - Attempt admin endpoints with PERSONAL account and verify 403 Forbidden
  
  - [ ]* 7.6 Write unit test for JWT authentication
    - **Property 8: JWT Authentication Required**
    - **Validates: Requirements 3.4**
    - Attempt endpoints without token and verify 401 Unauthorized
  
  - [ ]* 7.7 Write property test for pagination
    - **Property 16: Pagination Support**
    - **Validates: Requirements 8.1, 8.3**
    - Query with different page sizes and verify correct results and total count
  
  - [ ]* 7.8 Write property test for timestamp sorting
    - **Property 17: Timestamp Sorting**
    - **Validates: Requirements 8.2**
    - Create feedback with different timestamps and verify newest-first ordering
  
  - [ ]* 7.9 Write property test for response field completeness
    - **Property 18: Response Field Completeness**
    - **Validates: Requirements 8.5**
    - Query feedback and verify all required fields are present

- [ ] 8. Create global exception handler
  - [ ] 8.1 Create GlobalExceptionHandler with @ControllerAdvice
    - Handle MethodArgumentNotValidException (validation errors)
    - Handle AccessDeniedException (authorization errors)
    - Handle AuthenticationException (authentication errors)
    - Handle general exceptions
    - Return consistent error response format
    - _Requirements: 1.6, 3.2, 10.2, 10.3, 10.4_
  
  - [ ]* 8.2 Write unit tests for error handling
    - Test validation error responses (400)
    - Test authentication error responses (401)
    - Test authorization error responses (403)
    - Test server error responses (500)

- [ ] 9. Checkpoint - Ensure all backend tests pass
  - Run all unit and property tests
  - Verify all 21 correctness properties are implemented
  - Test API endpoints manually with Postman or curl
  - Ask the user if questions arise

- [ ] 10. Update SecurityConfig to allow feedback endpoints
  - [ ] 10.1 Update SecurityConfig.java
    - Ensure /api/feedback/** requires authentication
    - Verify JWT filter applies to feedback endpoints
    - _Requirements: 3.4, 12.1, 12.3_

- [ ] 11. Create frontend components
  - [ ] 11.1 Update Feedback.jsx for backend integration
    - Replace localStorage with API call to POST /api/feedback
    - Add JWT token to request headers
    - Handle success response (show message, clear form)
    - Handle error response (show validation errors)
    - Add loading state during submission
    - _Requirements: 13.1, 13.2, 13.6, 13.7_
  
  - [ ] 11.2 Update App_Feedback.jsx for backend integration
    - Replace hardcoded data with API call to GET /api/feedback
    - Add JWT token to request headers
    - Implement pagination controls
    - Implement status filter dropdown (ALL, NEW, REVIEWED)
    - Add "Mark as Reviewed" button for each feedback item
    - Implement CSV export button (triggers GET /api/feedback/export/csv)
    - Implement Excel export button (triggers GET /api/feedback/export/excel)
    - Handle file downloads with proper filenames
    - Add loading states during API operations
    - Handle error responses
    - Implement polling for real-time updates (every 30 seconds)
    - _Requirements: 13.3, 13.4, 13.5, 13.6, 13.7, 7.1, 7.2_

- [ ] 12. Create API testing scripts
  - [ ] 12.1 Create PowerShell script test-feedback-system.ps1
    - Test feedback submission as regular user
    - Test feedback retrieval as PROFESSIONAL user
    - Test access denial for PERSONAL user
    - Test marking feedback as reviewed
    - Test CSV export
    - Test Excel export
    - Test pagination and filtering
    - _Requirements: All_

- [ ] 13. Final checkpoint - End-to-end testing
  - Run backend application
  - Run frontend application
  - Test complete feedback submission flow
  - Test complete admin dashboard flow
  - Test export functionality
  - Verify multi-tenancy isolation
  - Verify access control
  - Ask the user if questions arise

## Notes

- Tasks marked with `*` are optional property-based tests that can be skipped for faster MVP
- Each task references specific requirements for traceability
- Property tests validate universal correctness properties with minimum 100 iterations
- Unit tests validate specific examples and edge cases
- Integration tests verify end-to-end flows
- The implementation follows a bottom-up approach to enable incremental validation
- Real-time updates use polling initially; WebSocket can be added later if needed
