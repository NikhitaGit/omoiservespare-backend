package com.omoikaneinnovations.omoiservespare.dto.ticket;

import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.util.List;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class AgentDashboardDTO {
    private List<TicketDTO> assignedTickets;
    private List<TicketDTO> unassignedTickets;
    private long openCount;
    private long inProgressCount;
    private long resolvedCount;
    private long closedCount;
}
