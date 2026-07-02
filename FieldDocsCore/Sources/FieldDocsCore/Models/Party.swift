import Foundation

public struct Party: Codable, Identifiable, Sendable {
    public let id: UUID
    public var fullName: String
    public var iin: String
    public var phone: String
    
    public init(
        id: UUID = UUID(),
        fullName: String = "",
        iin: String = "",
        phone: String = ""
    ) {
        self.id = id
        self.fullName = fullName
        self.iin = iin
        self.phone = phone
    }
    
    public var isIINValid: Bool {
        iin.count == 12 && iin.allSatisfy { $0.isNumber }
    }
}
