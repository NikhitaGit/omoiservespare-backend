package com.omoikaneinnovations.omoiservespare.dto;

import java.util.ArrayList;
import java.util.List;

public class MenuUploadResponseDTO {

    private int successCount;
    private List<String> errors = new ArrayList<>();

    public int getSuccessCount() {
        return successCount;
    }

    public void setSuccessCount(int successCount) {
        this.successCount = successCount;
    }

    public List<String> getErrors() {
        return errors;
    }

    public void addError(String error) {
        this.errors.add(error);
    }
}
