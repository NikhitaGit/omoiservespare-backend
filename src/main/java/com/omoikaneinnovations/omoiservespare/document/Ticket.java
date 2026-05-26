package com.omoikaneinnovations.omoiservespare.document;

import com.omoikaneinnovations.omoiservespare.enums.TicketPriority;
import com.omoikaneinnovations.omoiservespare.enums.TicketStatus;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;
import org.springframework.data.annotation.Id;
import org.springframework.data.mongodb.core.mapping.Document;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
@Document(collection = "tickets")
public class Ticket {
    
    @Id
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
    
    private List<TicketMessage> messages = new ArrayList<>();
    private List<String> attachments = new ArrayList<>();
    private List<String> tags = new ArrayList<>();
}
