package com.omoikaneinnovations.omoiservespare.dto;

import com.omoikaneinnovations.omoiservespare.domain.AccountType;

public class LoginResponse {

    private boolean success;
    private String message;
    private String accessToken;
    
    // User info fields
    private String email;
    private String companyName;
    private String phoneNumber;
    private AccountType accountType;

    // Constructor for simple responses (login request, errors)
    public LoginResponse(boolean success, String message, String accessToken) {
        this.success = success;
        this.message = message;
        this.accessToken = accessToken;
    }

    // Constructor for full response (after OTP verification)
    public LoginResponse(boolean success, String message, String accessToken, 
                        String email, String companyName, String phoneNumber, AccountType accountType) {
        this.success = success;
        this.message = message;
        this.accessToken = accessToken;
        this.email = email;
        this.companyName = companyName;
        this.phoneNumber = phoneNumber;
        this.accountType = accountType;
    }

    // Getters
    public boolean isSuccess() {
        return success;
    }

    public String getMessage() {
        return message;
    }

    public String getAccessToken() {
        return accessToken;
    }

    public String getEmail() {
        return email;
    }

    public String getCompanyName() {
        return companyName;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public AccountType getAccountType() {
        return accountType;
    }

    // Setters
    public void setSuccess(boolean success) {
        this.success = success;
    }

    public void setMessage(String message) {
        this.message = message;
    }

    public void setAccessToken(String accessToken) {
        this.accessToken = accessToken;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public void setCompanyName(String companyName) {
        this.companyName = companyName;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public void setAccountType(AccountType accountType) {
        this.accountType = accountType;
    }
}
