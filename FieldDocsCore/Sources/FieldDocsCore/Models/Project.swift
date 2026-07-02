import Foundation

public struct Project: Codable, Identifiable, Sendable {
    public let id: UUID
    public var name: String
    public var address: String
    public var createdAt: Date
    public var modifiedAt: Date
    
    public init(
        id: UUID = UUID(),
        name: String,
        address: String,
        createdAt: Date = Date(),
        modifiedAt: Date = Date()
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.createdAt = createdAt
        self.modifiedAt = modifiedAt
    }
}
