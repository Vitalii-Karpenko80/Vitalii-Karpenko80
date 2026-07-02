import SwiftUI
import FieldDocsCore

struct ContentView: View {
    @EnvironmentObject var store: AppStore
    @State private var showingNewCase = false
    
    var body: some View {
        NavigationStack {
            CasesListView()
                .navigationTitle("Мои акты")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button {
                            showingNewCase = true
                        } label: {
                            Image(systemName: "plus")
                        }
                    }
                }
                .sheet(isPresented: $showingNewCase) {
                    CreateCaseView(isPresented: $showingNewCase)
                }
        }
    }
}
