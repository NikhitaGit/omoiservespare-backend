package com.omoikaneinnovations.omoiservespare.dto.ticket;

import com.omoikaneinnovations.omoiservespare.enums.TicketPriority;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class CreateTicketRequest {
    
    @NotBlank(message = "Subject is required")
    private String subject;
    
    @NotBlank(message = "Description is required")
    private String description;
    
    private String category;
    
    @NotNull(message = "Priority is required")
    private TicketPriority priority;
    
    private String userPhone; // Will be auto-populated from user profile
}
