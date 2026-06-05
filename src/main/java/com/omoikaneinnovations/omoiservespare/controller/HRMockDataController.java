package com.omoikaneinnovations.omoiservespare.controller;

import com.omoikaneinnovations.omoiservespare.dto.HREmployeeDTO;
import com.omoikaneinnovations.omoiservespare.service.MockHRDataService;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * Controller for managing Mock HR Data
 * This allows you to view and manage the mock employee database
 */
@RestController
@RequestMapping("/api/hr-mock")
@CrossOrigin(origins = {"http://localhost:5173", "http://localhost:5174"}, allowCredentials = "true")
public class HRMockDataController {

    private final MockHRDataService mockHRDataService;

    public HRMockDataController(MockHRDataService mockHRDataService) {
        this.mockHRDataService = mockHRDataService;
    }

    /**
     * Get all employees in the mock HR system
     */
    @GetMapping("/employees")
    public ResponseEntity<List<HREmployeeDTO>> getAllEmployees() {
        List<HREmployeeDTO> employees = mockHRDataService.getActiveEmployees();
        return ResponseEntity.ok(employees);
    }

    /**
     * Get employee by email
     */
    @GetMapping("/employees/by-email/{email}")
    public ResponseEntity<HREmployeeDTO> getEmployeeByEmail(@PathVariable String email) {
        return mockHRDataService.findByEmail(email)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * Get employee by phone
     */
    @GetMapping("/employees/by-phone/{phone}")
    public ResponseEntity<HREmployeeDTO> getEmployeeByPhone(@PathVariable String phone) {
        return mockHRDataService.findByPhone(phone)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    /**
     * Get employees by company
     */
    @GetMapping("/employees/by-company/{companyName}")
    public ResponseEntity<List<HREmployeeDTO>> getEmployeesByCompany(@PathVariable String companyName) {
        List<HREmployeeDTO> employees = mockHRDataService.getEmployeesByCompany(companyName);
        return ResponseEntity.ok(employees);
    }

    /**
     * Get HR system statistics
     */
    @GetMapping("/statistics")
    public ResponseEntity<Map<String, Object>> getStatistics() {
        return ResponseEntity.ok(mockHRDataService.getStatistics());
    }

    /**
     * Add a new employee to mock HR system
     */
    @PostMapping("/employees")
    public ResponseEntity<String> addEmployee(@RequestBody HREmployeeDTO employee) {
        mockHRDataService.addNewEmployee(employee);
        return ResponseEntity.ok("Employee added successfully: " + employee.getEmail());
    }

    /**
     * Remove employee from mock HR system
     */
    @DeleteMapping("/employees/{email}")
    public ResponseEntity<String> removeEmployee(@PathVariable String email) {
        mockHRDataService.removeEmployee(email);
        return ResponseEntity.ok("Employee removed: " + email);
    }

    /**
     * Reload all mock data
     */
    @PostMapping("/reload")
    public ResponseEntity<String> reloadData() {
        mockHRDataService.reloadData();
        return ResponseEntity.ok("Mock HR data reloaded successfully");
    }

    /**
     * Validate company
     */
    @GetMapping("/companies/validate/{companyName}")
    public ResponseEntity<Boolean> validateCompany(@PathVariable String companyName) {
        boolean isValid = mockHRDataService.isValidCompany(companyName);
        return ResponseEntity.ok(isValid);
    }
}