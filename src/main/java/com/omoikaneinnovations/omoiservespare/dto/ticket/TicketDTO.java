package com.omoikaneinnovations.omoiservespare.dto.ticket;

import com.omoikaneinnovations.omoiservespare.enums.TicketPriority;
import com.omoikaneinnovations.omoiservespare.enums.TicketStatus;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TicketDTO {
    private String id;
    private String ticketNumber;
    private String userId;
    private String userName;
    private String userEmail;
    private String userPhone;
    private String subject;
    private String description;
    private String category;
    private TicketPriority priority;
    private TicketStatus status;
    private String assignedAgentId;
    private String assignedAgentName;
    private LocalDateTime createdAt;
    private LocalDateTime updatedAt;
    private LocalDateTime resolvedAt;
    private LocalDateTime closedAt;
    private int unreadMessageCount;
    private List<String> tags;
}
