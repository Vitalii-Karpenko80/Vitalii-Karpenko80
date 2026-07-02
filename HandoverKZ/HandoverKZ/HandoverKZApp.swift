import SwiftUI
import FieldDocsCore

@main
struct HandoverKZApp: App {
    @StateObject private var store = AppStore()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}

@MainActor
class AppStore: ObservableObject {
    @Published var cases: [HandoverCase] = []
    let repository = HandoverRepository()
    
    init() {
        loadCases()
    }
    
    func loadCases() {
        do {
            cases = try repository.loadAll()
        } catch {
            print("Failed to load cases: \(error)")
            cases = []
        }
    }
    
    func saveCase(_ handoverCase: HandoverCase) {
        do {
            try repository.save(handoverCase)
            loadCases()
        } catch {
            print("Failed to save case: \(error)")
        }
    }
    
    func deleteCase(_ handoverCase: HandoverCase) {
        do {
            try repository.delete(id: handoverCase.id)
            loadCases()
        } catch {
            print("Failed to delete case: \(error)")
        }
    }
}
