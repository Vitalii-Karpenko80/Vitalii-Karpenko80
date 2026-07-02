import SwiftUI
import FieldDocsCore

struct CreateCaseView: View {
    @EnvironmentObject var store: AppStore
    @Binding var isPresented: Bool
    
    @State private var projectName = ""
    @State private var projectAddress = ""
    
    @State private var landlordName = ""
    @State private var landlordIIN = ""
    @State private var landlordPhone = ""
    
    @State private var tenantName = ""
    @State private var tenantIIN = ""
    @State private var tenantPhone = ""
    
    @State private var depositAmount = ""
    
    @State private var showingValidationError = false
    @State private var validationMessage = ""
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Объект") {
                    MSTextField(
                        title: "Название",
                        text: $projectName,
                        placeholder: "Например: Квартира на Абая"
                    )
                    
                    MSTextField(
                        title: "Адрес",
                        text: $projectAddress,
                        placeholder: "Например: пр. Абая, 123, кв. 45"
                    )
                }
                
                Section("Арендодатель") {
                    MSTextField(
                        title: "ФИО",
                        text: $landlordName,
                        placeholder: "Иванов Иван Иванович"
                    )
                    
                    MSTextField(
                        title: "ИИН (12 цифр)",
                        text: $landlordIIN,
                        placeholder: "123456789012",
                        keyboardType: .numberPad
                    )
                    .onChange(of: landlordIIN) { _, newValue in
                        if newValue.count > 12 {
                            landlordIIN = String(newValue.prefix(12))
                        }
                    }
                    
                    MSTextField(
                        title: "Телефон",
                        text: $landlordPhone,
                        placeholder: "+7 777 123 45 67",
                        keyboardType: .phonePad
                    )
                }
                
                Section("Арендатор") {
                    MSTextField(
                        title: "ФИО",
                        text: $tenantName,
                        placeholder: "Петров Петр Петрович"
                    )
                    
                    MSTextField(
                        title: "ИИН (12 цифр)",
                        text: $tenantIIN,
                        placeholder: "987654321098",
                        keyboardType: .numberPad
                    )
                    .onChange(of: tenantIIN) { _, newValue in
                        if newValue.count > 12 {
                            tenantIIN = String(newValue.prefix(12))
                        }
                    }
                    
                    MSTextField(
                        title: "Телефон",
                        text: $tenantPhone,
                        placeholder: "+7 777 987 65 43",
                        keyboardType: .phonePad
                    )
                }
                
                Section("Залог") {
                    MSTextField(
                        title: "Сумма (₸)",
                        text: $depositAmount,
                        placeholder: "100000",
                        keyboardType: .numberPad
                    )
                }
            }
            .navigationTitle("Новый акт")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Отмена") {
                        isPresented = false
                    }
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Создать") {
                        createCase()
                    }
                }
            }
            .alert("Ошибка", isPresented: $showingValidationError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(validationMessage)
            }
        }
    }
    
    private func createCase() {
        guard !projectName.isEmpty else {
            validationMessage = "Введите название объекта"
            showingValidationError = true
            return
        }
        
        guard !projectAddress.isEmpty else {
            validationMessage = "Введите адрес объекта"
            showingValidationError = true
            return
        }
        
        guard landlordIIN.count == 12, landlordIIN.allSatisfy({ $0.isNumber }) else {
            validationMessage = "ИИН арендодателя должен содержать 12 цифр"
            showingValidationError = true
            return
        }
        
        guard tenantIIN.count == 12, tenantIIN.allSatisfy({ $0.isNumber }) else {
            validationMessage = "ИИН арендатора должен содержать 12 цифр"
            showingValidationError = true
            return
        }
        
        let deposit = Decimal(string: depositAmount) ?? 0
        
        let project = Project(
            name: projectName,
            address: projectAddress
        )
        
        let landlord = Party(
            fullName: landlordName,
            iin: landlordIIN,
            phone: landlordPhone
        )
        
        let tenant = Party(
            fullName: tenantName,
            iin: tenantIIN,
            phone: tenantPhone
        )
        
        let handoverCase = HandoverCase(
            project: project,
            landlord: landlord,
            tenant: tenant,
            depositAmount: deposit
        )
        
        store.saveCase(handoverCase)
        isPresented = false
    }
}
