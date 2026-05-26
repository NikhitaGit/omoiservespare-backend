package com.omoikaneinnovations.omoiservespare.dto.ticket;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class TicketDetailsDTO {
    private TicketDTO ticket;
    private List<TicketMessageDTO> messages;
}
