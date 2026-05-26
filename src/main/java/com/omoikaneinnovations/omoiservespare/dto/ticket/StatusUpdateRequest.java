package com.omoikaneinnovations.omoiservespare.dto.ticket;

import com.omoikaneinnovations.omoiservespare.enums.TicketStatus;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import jakarta.validation.constraints.NotNull;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class StatusUpdateRequest {
    
    @NotNull(message = "Status is required")
    private TicketStatus status;
    
    private String message; // Optional message when changing status
}
