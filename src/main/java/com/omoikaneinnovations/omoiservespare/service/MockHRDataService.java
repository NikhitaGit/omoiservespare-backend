package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.dto.HREmployeeDTO;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import jakarta.annotation.PostConstruct;
import java.util.*;
import java.util.concurrent.ConcurrentHashMap;

/**
 * Mock HR Data Service - Simulates a Company HR Application Database
 * This service provides production-grade mock data for testing HR integration
 */
@Service
public class MockHRDataService {

    private static final Logger logger = LoggerFactory.getLogger(MockHRDataService.class);

    // In-memory "database" for mock HR data
    private final Map<String, HREmployeeDTO> employeesByEmail = new ConcurrentHashMap<>();
    private final Map<String, HREmployeeDTO> employeesByPhone = new ConcurrentHashMap<>();
    private final Map<String, HREmployeeDTO> employeesById = new ConcurrentHashMap<>();
    private final Set<String> validCompanies = new HashSet<>();

    @PostConstruct
    public void initializeMockData() {
        logger.info("Initializing Mock HR Data Service...");
        loadMockCompanies();
        loadMockEmployees();
        logger.info("Mock HR Data initialized: {} employees, {} companies", 
            employeesByEmail.size(), validCompanies.size());
    }

    /**
     * Load mock companies into the system
     */
    private void loadMockCompanies() {
        validCompanies.add("Omoiservespare Pvt Ltd");
        validCompanies.add("OmoiServerspare Pvt Ltd"); // Alternate spelling
        validCompanies.add("Omoikane Innovations");
        validCompanies.add("Tech Corp");
        validCompanies.add("Innovation Labs");
    }

    /**
     * Load mock employees into the system
     * This simulates employee data from HR application
     */
    private void loadMockEmployees() {
        // Company 1: Omoiservespare Pvt Ltd
        addEmployee(createEmployee(
            "EMP001",
            "Nikita",
            "A",
            "nikita.a@omoikaneinnovations.com",
            "Engineering",
            "Software Engineer",
            "+91-9876543210",
            "2023-01-15",
            "active",
            "manager@omoikaneinnovations.com",
            "Omoiservespare Pvt Ltd"
        ));

        addEmployee(createEmployee(
            "EMP002",
            "Lata",
            "B",
            "lata.b@omoikaneinnovations.com",
            "Engineering",
            "Senior Software Engineer",
            "+91-9876543211",
            "2022-06-10",
            "active",
            "manager@omoikaneinnovations.com",
            "Omoiservespare Pvt Ltd"
        ));

        addEmployee(createEmployee(
            "EMP003",
            "Rahul",
            "Sharma",
            "bd@omoikaneinnovations.com",
            "Engineering",
            "Engineering Manager",
            "+91-9876543212",
            "2021-03-20",
            "active",
            "cto@omoikaneinnovations.com",
            "Omoiservespare Pvt Ltd"
        ));

        addEmployee(createEmployee(
            "EMP004",
            "Priya",
            "Patel",
            "info@omoikaneinnovations.com",
            "Product",
            "Product Manager",
            "+91-9876543213",
            "2022-08-15",
            "active",
            "cpo@omoikaneinnovations.com",
            "Omoiservespare Pvt Ltd"
        ));

        addEmployee(createEmployee(
            "EMP005",
            "Vishnu",
            "Vardhan",
            "vishnuvardhan.a@omoikaneinnovations.com",
            "Engineering",
            "DevOps Engineer",
            "+91-9876543214",
            "2023-02-01",
            "active",
            "manager@omoikaneinnovations.com",
            "Omoiservespare Pvt Ltd"
        ));

        // Company 2: Omoikane Innovations
        addEmployee(createEmployee(
            "EMP101",
            "Aishwarya",
            "N",
            "aishwarya.n@omoikaneinnovations.com",
            "Engineering",
            "Software Engineer",
            "+91-9876543220",
            "2023-03-10",
            "active",
            "tech.lead@omoikaneinnovations.com",
            "Omoikane Innovations"
        ));

        addEmployee(createEmployee(
            "EMP102",
            "Mahesh",
            "Panchal",
            "mahesh.p@omoikaneinnovations.com",
            "Design",
            "UI/UX Designer",
            "+91-9876543221",
            "2022-11-05",
            "active",
            "design.lead@omoikaneinnovations.com",
            "Omoikane Innovations"
        ));

        // Company 3: Tech Corp
        addEmployee(createEmployee(
            "EMP201",
            "Michael",
            "Johnson",
            "michael.johnson@techcorp.com",
            "Engineering",
            "Tech Lead",
            "+91-9876543230",
            "2021-05-15",
            "active",
            "director@techcorp.com",
            "Tech Corp"
        ));

        addEmployee(createEmployee(
            "EMP202",
            "Sarah",
            "Williams",
            "sarah.williams@techcorp.com",
            "HR",
            "HR Manager",
            "+91-9876543231",
            "2020-09-20",
            "active",
            "hr.director@techcorp.com",
            "Tech Corp"
        ));

        // Inactive employee example
        addEmployee(createEmployee(
            "EMP999",
            "Inactive",
            "User",
            "inactive.user@omoikaneinnovations.com",
            "Engineering",
            "Software Engineer",
            "+91-9876543299",
            "2020-01-01",
            "inactive",
            "manager@omoikaneinnovations.com",
            "Omoiservespare Pvt Ltd"
        ));

        logger.info("Loaded {} mock employees", employeesByEmail.size());
    }

    /**
     * Create an employee DTO
     */
    private HREmployeeDTO createEmployee(
            String employeeId,
            String firstName,
            String lastName,
            String email,
            String department,
            String jobTitle,
            String phoneNumber,
            String hireDate,
            String status,
            String managerEmail,
            String companyName) {

        HREmployeeDTO employee = new HREmployeeDTO();
        employee.setEmployeeId(employeeId);
        employee.setFirstName(firstName);
        employee.setLastName(lastName);
        employee.setEmail(email);
        employee.setDepartment(department);
        employee.setJobTitle(jobTitle);
        employee.setPhoneNumber(phoneNumber);
        employee.setHireDate(hireDate);
        employee.setStatus(status);
        employee.setManagerEmail(managerEmail);
        employee.setCompanyName(companyName);

        return employee;
    }

    /**
     * Add employee to all lookup maps
     */
    private void addEmployee(HREmployeeDTO employee) {
        employeesByEmail.put(employee.getEmail().toLowerCase(), employee);
        employeesByPhone.put(employee.getPhoneNumber(), employee);
        employeesById.put(employee.getEmployeeId(), employee);
    }

    /**
     * Find employee by email
     */
    public Optional<HREmployeeDTO> findByEmail(String email) {
        if (email == null) {
            return Optional.empty();
        }
        HREmployeeDTO employee = employeesByEmail.get(email.toLowerCase());
        if (employee != null) {
            logger.info("Found employee in mock HR data: {}", email);
        } else {
            logger.warn("Employee not found in mock HR data: {}", email);
        }
        return Optional.ofNullable(employee);
    }

    /**
     * Find employee by phone number
     */
    public Optional<HREmployeeDTO> findByPhone(String phoneNumber) {
        if (phoneNumber == null) {
            return Optional.empty();
        }
        HREmployeeDTO employee = employeesByPhone.get(phoneNumber);
        if (employee != null) {
            logger.info("Found employee in mock HR data by phone: {}", phoneNumber);
        } else {
            logger.warn("Employee not found in mock HR data by phone: {}", phoneNumber);
        }
        return Optional.ofNullable(employee);
    }

    /**
     * Find employee by ID
     */
    public Optional<HREmployeeDTO> findById(String employeeId) {
        if (employeeId == null) {
            return Optional.empty();
        }
        return Optional.ofNullable(employeesById.get(employeeId));
    }

    /**
     * Validate if company exists
     */
    public boolean isValidCompany(String companyName) {
        if (companyName == null) {
            return false;
        }
        
        // Exact match
        if (validCompanies.contains(companyName)) {
            return true;
        }
        
        // Partial match (case-insensitive)
        String lowerCompanyName = companyName.toLowerCase();
        return validCompanies.stream()
            .anyMatch(company -> company.toLowerCase().contains(lowerCompanyName) ||
                                lowerCompanyName.contains(company.toLowerCase()));
    }

    /**
     * Get all employees for a company
     */
    public List<HREmployeeDTO> getEmployeesByCompany(String companyName) {
        return employeesByEmail.values().stream()
            .filter(emp -> emp.getCompanyName().equalsIgnoreCase(companyName))
            .toList();
    }

    /**
     * Get all active employees
     */
    public List<HREmployeeDTO> getActiveEmployees() {
        return employeesByEmail.values().stream()
            .filter(emp -> "active".equalsIgnoreCase(emp.getStatus()))
            .toList();
    }

    /**
     * Get statistics
     */
    public Map<String, Object> getStatistics() {
        Map<String, Object> stats = new HashMap<>();
        stats.put("totalEmployees", employeesByEmail.size());
        stats.put("totalCompanies", validCompanies.size());
        stats.put("activeEmployees", getActiveEmployees().size());
        stats.put("companies", validCompanies);
        return stats;
    }

    /**
     * Add a new employee dynamically (for testing)
     */
    public void addNewEmployee(HREmployeeDTO employee) {
        addEmployee(employee);
        logger.info("Added new employee to mock HR data: {}", employee.getEmail());
    }

    /**
     * Remove employee (for testing)
     */
    public void removeEmployee(String email) {
        HREmployeeDTO employee = employeesByEmail.remove(email.toLowerCase());
        if (employee != null) {
            employeesByPhone.remove(employee.getPhoneNumber());
            employeesById.remove(employee.getEmployeeId());
            logger.info("Removed employee from mock HR data: {}", email);
        }
    }

    /**
     * Clear all data (for testing)
     */
    public void clearAllData() {
        employeesByEmail.clear();
        employeesByPhone.clear();
        employeesById.clear();
        validCompanies.clear();
        logger.warn("Cleared all mock HR data");
    }

    /**
     * Reload data (for testing)
     */
    public void reloadData() {
        clearAllData();
        initializeMockData();
        logger.info("Reloaded mock HR data");
    }
}
