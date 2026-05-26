package com.omoikaneinnovations.omoiservespare.service;

import com.omoikaneinnovations.omoiservespare.dto.FeedbackDTO;
import org.apache.commons.csv.CSVFormat;
import org.apache.commons.csv.CSVPrinter;
import org.apache.poi.ss.usermodel.*;
import org.apache.poi.xssf.usermodel.XSSFWorkbook;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Service;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.StringWriter;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
public class ExportService {
    
    private static final Logger log = LoggerFactory.getLogger(ExportService.class);
    private static final DateTimeFormatter DATE_FORMATTER = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm:ss");
    
    /**
     * Export feedback to CSV format
     */
    public byte[] exportToCSV(List<FeedbackDTO> feedbackList) {
        log.info("Exporting {} feedback entries to CSV", feedbackList.size());
        
        try (StringWriter writer = new StringWriter();
             CSVPrinter csvPrinter = new CSVPrinter(writer, CSVFormat.DEFAULT
                 .withHeader("ID", "Rating", "Comments", "User Email", "Company Name", 
                            "Status", "Submitted At", "Reviewed At"))) {
            
            for (FeedbackDTO feedback : feedbackList) {
                csvPrinter.printRecord(
                    feedback.getId(),
                    feedback.getRating(),
                    feedback.getComments(),
                    feedback.getUserEmail(),
                    feedback.getCompanyName(),
                    feedback.getStatus(),
                    feedback.getCreatedAt() != null ? feedback.getCreatedAt().format(DATE_FORMATTER) : "",
                    feedback.getReviewedAt() != null ? feedback.getReviewedAt().format(DATE_FORMATTER) : ""
                );
            }
            
            csvPrinter.flush();
            return writer.toString().getBytes();
            
        } catch (IOException e) {
            log.error("Failed to export CSV", e);
            throw new RuntimeException("Failed to export CSV: " + e.getMessage(), e);
        }
    }
    
    /**
     * Export feedback to Excel format
     */
    public byte[] exportToExcel(List<FeedbackDTO> feedbackList) {
        log.info("Exporting {} feedback entries to Excel", feedbackList.size());
        
        try (Workbook workbook = new XSSFWorkbook();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            
            Sheet sheet = workbook.createSheet("Feedback");
            
            // Create header row with bold font
            Row headerRow = sheet.createRow(0);
            CellStyle headerStyle = workbook.createCellStyle();
            Font headerFont = workbook.createFont();
            headerFont.setBold(true);
            headerStyle.setFont(headerFont);
            
            String[] headers = {"ID", "Rating", "Comments", "User Email", "Company Name", 
                               "Status", "Submitted At", "Reviewed At"};
            
            for (int i = 0; i < headers.length; i++) {
                Cell cell = headerRow.createCell(i);
                cell.setCellValue(headers[i]);
                cell.setCellStyle(headerStyle);
            }
            
            // Create data rows
            int rowNum = 1;
            for (FeedbackDTO feedback : feedbackList) {
                Row row = sheet.createRow(rowNum++);
                
                row.createCell(0).setCellValue(feedback.getId());
                row.createCell(1).setCellValue(feedback.getRating());
                row.createCell(2).setCellValue(feedback.getComments());
                row.createCell(3).setCellValue(feedback.getUserEmail());
                row.createCell(4).setCellValue(feedback.getCompanyName());
                row.createCell(5).setCellValue(feedback.getStatus().toString());
                row.createCell(6).setCellValue(
                    feedback.getCreatedAt() != null ? feedback.getCreatedAt().format(DATE_FORMATTER) : ""
                );
                row.createCell(7).setCellValue(
                    feedback.getReviewedAt() != null ? feedback.getReviewedAt().format(DATE_FORMATTER) : ""
                );
            }
            
            // Auto-size columns
            for (int i = 0; i < headers.length; i++) {
                sheet.autoSizeColumn(i);
            }
            
            workbook.write(out);
            return out.toByteArray();
            
        } catch (IOException e) {
            log.error("Failed to export Excel", e);
            throw new RuntimeException("Failed to export Excel: " + e.getMessage(), e);
        }
    }
}
