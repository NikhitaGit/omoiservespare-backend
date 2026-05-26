package com.omoikaneinnovations.omoiservespare.dto.ticket;

import com.omoikaneinnovations.omoiservespare.enums.SenderType;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.time.LocalDateTime;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TicketMessageDTO {
    private String messageId;
    private String senderId;
    private String senderName;
    private SenderType senderType;
    private String message;
    private LocalDateTime timestamp;
    private boolean isRead;
}
