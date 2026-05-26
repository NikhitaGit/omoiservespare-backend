package com.omoikaneinnovations.omoiservespare.repository;

import com.omoikaneinnovations.omoiservespare.document.Ticket;
import com.omoikaneinnovations.omoiservespare.enums.TicketStatus;
import org.springframework.data.mongodb.repository.MongoRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface TicketRepository extends MongoRepository<Ticket, String> {
    
    List<Ticket> findByUserId(String userId);
    
    List<Ticket> findByAssignedAgentId(String agentId);
    
    List<Ticket> findByStatus(TicketStatus status);
    
    Optional<Ticket> findByTicketNumber(String ticketNumber);
    
    List<Ticket> findByAssignedAgentIdIsNull();
    
    // For dashboard counts
    long countByStatus(TicketStatus status);
    
    long countByUserIdAndStatus(String userId, TicketStatus status);
    
    long countByAssignedAgentIdAndStatus(String agentId, TicketStatus status);
    
    // Find all tickets ordered by creation date
    List<Ticket> findAllByOrderByCreatedAtDesc();
    
    List<Ticket> findByUserIdOrderByCreatedAtDesc(String userId);
    
    List<Ticket> findByAssignedAgentIdOrderByCreatedAtDesc(String agentId);
}
