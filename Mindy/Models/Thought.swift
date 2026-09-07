//
//  Thought.swift
//  Mindy
//
//  Модель для хранения распознанной мысли
//

import Foundation
import CloudKit

struct Thought: Identifiable, Codable {
    let id: UUID
    let originalText: String
    let task: String?
    let subject: String?
    let when: Date?
    let context: String?
    let priority: String?
    let taskType: String?
    let createdAt: Date
    var isProcessed: Bool
    var cloudKitRecordID: String? // CloudKit record identifier
    var lastModified: Date
    
    init(
        id: UUID = UUID(),
        originalText: String,
        task: String? = nil,
        subject: String? = nil,
        when: Date? = nil,
        context: String? = nil,
        priority: String? = nil,
        taskType: String? = nil,
        createdAt: Date = Date(),
        isProcessed: Bool = false,
        cloudKitRecordID: String? = nil,
        lastModified: Date = Date()
    ) {
        self.id = id
        self.originalText = originalText
        self.task = task
        self.subject = subject
        self.when = when
        self.context = context
        self.priority = priority
        self.taskType = taskType
        self.createdAt = createdAt
        self.isProcessed = isProcessed
        self.cloudKitRecordID = cloudKitRecordID
        self.lastModified = lastModified
    }
    
    var formattedWhen: String {
        guard let when = when else { return "Без даты" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        formatter.locale = Locale(identifier: "ru_RU")
        return formatter.string(from: when)
    }
    
    var priorityColor: String {
        switch priority {
        case "high": return "🔴"
        case "medium": return "🟡"
        case "low": return "🟢"
        default: return ""
        }
    }
    
    var typeIcon: String {
        switch taskType {
        case "call": return "phone.fill"
        case "meeting": return "person.2.fill"
        case "purchase": return "cart.fill"
        case "reminder": return "bell.fill"
        case "note": return "note.text"
        default: return "checkmark.circle.fill"
        }
    }
    
    // MARK: - CloudKit Support
    
    static let recordType = "Thought"
    
    // Convert to CloudKit Record
    func toCKRecord() -> CKRecord {
        let recordID: CKRecord.ID
        if let recordIDString = cloudKitRecordID {
            recordID = CKRecord.ID(recordName: recordIDString)
        } else {
            recordID = CKRecord.ID(recordName: id.uuidString)
        }
        
        let record = CKRecord(recordType: Self.recordType, recordID: recordID)
        record["id"] = id.uuidString as CKRecordValue
        record["originalText"] = originalText as CKRecordValue
        record["task"] = task as CKRecordValue?
        record["subject"] = subject as CKRecordValue?
        record["when"] = when as CKRecordValue?
        record["context"] = context as CKRecordValue?
        record["priority"] = priority as CKRecordValue?
        record["taskType"] = taskType as CKRecordValue?
        record["createdAt"] = createdAt as CKRecordValue
        record["isProcessed"] = (isProcessed ? 1 : 0) as CKRecordValue
        record["lastModified"] = lastModified as CKRecordValue
        
        return record
    }
    
    // Create from CloudKit Record
    static func from(_ record: CKRecord) -> Thought? {
        guard
            let idString = record["id"] as? String,
            let id = UUID(uuidString: idString),
            let originalText = record["originalText"] as? String,
            let createdAt = record["createdAt"] as? Date,
            let lastModified = record["lastModified"] as? Date
        else {
            return nil
        }
        
        let isProcessedInt = record["isProcessed"] as? Int ?? 0
        
        return Thought(
            id: id,
            originalText: originalText,
            task: record["task"] as? String,
            subject: record["subject"] as? String,
            when: record["when"] as? Date,
            context: record["context"] as? String,
            priority: record["priority"] as? String,
            taskType: record["taskType"] as? String,
            createdAt: createdAt,
            isProcessed: isProcessedInt == 1,
            cloudKitRecordID: record.recordID.recordName,
            lastModified: lastModified
        )
    }
}
