import Foundation

public struct Signature: Codable, Identifiable, Sendable {
    public let id: UUID
    public var fileName: String
    public var partyId: UUID
    public var timestamp: Date
    
    public init(
        id: UUID = UUID(),
        fileName: String,
        partyId: UUID,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.fileName = fileName
        self.partyId = partyId
        self.timestamp = timestamp
    }
    
    public func absolutePath(in directory: URL) -> URL {
        directory.appendingPathComponent(fileName)
    }
}
