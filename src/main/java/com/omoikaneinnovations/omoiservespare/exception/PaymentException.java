package com.omoikaneinnovations.omoiservespare.exception;

public class PaymentException extends RuntimeException {
    private String errorCode;
    private String errorMessage;

    public PaymentException(String message) {
        super(message);
        this.errorMessage = message;
    }

    public PaymentException(String errorCode, String message) {
        super(message);
        this.errorCode = errorCode;
        this.errorMessage = message;
    }

    public PaymentException(String message, Throwable cause) {
        super(message, cause);
        this.errorMessage = message;
    }

    public String getErrorCode() {
        return errorCode;
    }

    public String getErrorMessage() {
        return errorMessage;
    }
}