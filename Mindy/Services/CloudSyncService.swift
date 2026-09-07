//
//  CloudSyncService.swift
//  Mindy
//
//  Сервис для синхронизации задач через iCloud CloudKit
//

import Foundation
import CloudKit
import Combine

@MainActor
class CloudSyncService: ObservableObject {
    @Published var isSyncing = false
    @Published var lastSyncDate: Date?
    @Published var syncError: String?
    @Published var iCloudAvailable = false
    
    private let container: CKContainer
    private let privateDatabase: CKDatabase
    private let userDefaults = UserDefaults.standard
    private let syncEnabledKey = "cloud_sync_enabled"
    private let lastSyncKey = "last_sync_date"
    
    var syncEnabled: Bool {
        get {
            userDefaults.bool(forKey: syncEnabledKey)
        }
        set {
            userDefaults.set(newValue, forKey: syncEnabledKey)
            if newValue {
                Task {
                    await performInitialSync()
                }
            }
        }
    }
    
    init() {
        self.container = CKContainer.default()
        self.privateDatabase = container.privateCloudDatabase
        
        if let lastSync = userDefaults.object(forKey: lastSyncKey) as? Date {
            self.lastSyncDate = lastSync
        }
        
        Task {
            await checkiCloudStatus()
        }
    }
    
    // MARK: - iCloud Status
    
    func checkiCloudStatus() async {
        do {
            let status = try await container.accountStatus()
            iCloudAvailable = (status == .available)
            
            if !iCloudAvailable {
                syncError = "iCloud недоступен. Войдите в iCloud в настройках."
            }
        } catch {
            iCloudAvailable = false
            syncError = "Ошибка проверки iCloud: \(error.localizedDescription)"
        }
    }
    
    // MARK: - Sync Operations
    
    func performInitialSync() async {
        guard syncEnabled && iCloudAvailable else { return }
        
        isSyncing = true
        syncError = nil
        
        do {
            // Fetch all records from CloudKit
            let query = CKQuery(recordType: Thought.recordType, predicate: NSPredicate(value: true))
            query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
            
            let (matchResults, _) = try await privateDatabase.records(matching: query)
            
            var cloudThoughts: [Thought] = []
            
            for (_, result) in matchResults {
                switch result {
                case .success(let record):
                    if let thought = Thought.from(record) {
                        cloudThoughts.append(thought)
                    }
                case .failure(let error):
                    print("❌ Ошибка загрузки записи: \(error)")
                }
            }
            
            lastSyncDate = Date()
            userDefaults.set(lastSyncDate, forKey: lastSyncKey)
            
            print("✅ Начальная синхронизация завершена: \(cloudThoughts.count) задач")
            
        } catch {
            syncError = "Ошибка синхронизации: \(error.localizedDescription)"
            print("❌ Ошибка синхронизации: \(error)")
        }
        
        isSyncing = false
    }
    
    func uploadThought(_ thought: Thought) async throws {
        guard syncEnabled && iCloudAvailable else { return }
        
        let record = thought.toCKRecord()
        
        do {
            let _ = try await privateDatabase.save(record)
            print("✅ Задача загружена в iCloud: \(thought.task ?? "без названия")")
        } catch {
            syncError = "Ошибка загрузки задачи: \(error.localizedDescription)"
            throw error
        }
    }
    
    func uploadThoughts(_ thoughts: [Thought]) async throws {
        guard syncEnabled && iCloudAvailable else { return }
        
        isSyncing = true
        
        let records = thoughts.map { $0.toCKRecord() }
        
        do {
            let modifyOperation = CKModifyRecordsOperation(recordsToSave: records, recordIDsToDelete: nil)
            modifyOperation.savePolicy = .changedKeys
            
            try await privateDatabase.modifyRecords(
                saving: records,
                deleting: [],
                savePolicy: .changedKeys
            )
            
            lastSyncDate = Date()
            userDefaults.set(lastSyncDate, forKey: lastSyncKey)
            
            print("✅ Массовая загрузка: \(records.count) задач")
            
        } catch {
            syncError = "Ошибка массовой загрузки: \(error.localizedDescription)"
            throw error
        }
        
        isSyncing = false
    }
    
    func fetchThoughts() async throws -> [Thought] {
        guard syncEnabled && iCloudAvailable else { return [] }
        
        isSyncing = true
        
        let query = CKQuery(recordType: Thought.recordType, predicate: NSPredicate(value: true))
        query.sortDescriptors = [NSSortDescriptor(key: "createdAt", ascending: false)]
        
        var thoughts: [Thought] = []
        
        do {
            let (matchResults, _) = try await privateDatabase.records(matching: query)
            
            for (_, result) in matchResults {
                switch result {
                case .success(let record):
                    if let thought = Thought.from(record) {
                        thoughts.append(thought)
                    }
                case .failure(let error):
                    print("❌ Ошибка загрузки записи: \(error)")
                }
            }
            
            lastSyncDate = Date()
            userDefaults.set(lastSyncDate, forKey: lastSyncKey)
            
            print("✅ Загружено \(thoughts.count) задач из iCloud")
            
        } catch {
            syncError = "Ошибка загрузки: \(error.localizedDescription)"
            throw error
        }
        
        isSyncing = false
        return thoughts
    }
    
    func deleteThought(_ thought: Thought) async throws {
        guard syncEnabled && iCloudAvailable else { return }
        
        guard let recordIDString = thought.cloudKitRecordID else {
            print("⚠️ У задачи нет CloudKit ID, удаление пропущено")
            return
        }
        
        let recordID = CKRecord.ID(recordName: recordIDString)
        
        do {
            let _ = try await privateDatabase.deleteRecord(withID: recordID)
            print("✅ Задача удалена из iCloud")
        } catch {
            syncError = "Ошибка удаления: \(error.localizedDescription)"
            throw error
        }
    }
    
    func syncNow() async {
        await performInitialSync()
    }
    
    // MARK: - Conflict Resolution
    
    func resolveConflicts(local: [Thought], cloud: [Thought]) -> [Thought] {
        var merged: [String: Thought] = [:]
        
        // Start with cloud thoughts
        for thought in cloud {
            merged[thought.id.uuidString] = thought
        }
        
        // Merge local thoughts, preferring newer lastModified
        for localThought in local {
            let key = localThought.id.uuidString
            if let cloudThought = merged[key] {
                // Keep the one with latest modification date
                if localThought.lastModified > cloudThought.lastModified {
                    merged[key] = localThought
                }
            } else {
                // Local-only thought
                merged[key] = localThought
            }
        }
        
        return Array(merged.values).sorted { $0.createdAt > $1.createdAt }
    }
}
