package com.omoikaneinnovations.omoiservespare.exception;

public class FraudDetectedException extends PaymentException {
    private String riskLevel;
    private Double riskScore;

    public FraudDetectedException(String riskLevel, Double riskScore, String message) {
        super("FRAUD_DETECTED", message);
        this.riskLevel = riskLevel;
        this.riskScore = riskScore;
    }

    public String getRiskLevel() {
        return riskLevel;
    }

    public Double getRiskScore() {
        return riskScore;
    }
}