import Foundation

public struct Photo: Codable, Identifiable, Sendable {
    public let id: UUID
    public var fileName: String
    public var ownerId: UUID
    public var timestamp: Date
    public var caption: String?
    
    public init(
        id: UUID = UUID(),
        fileName: String,
        ownerId: UUID,
        timestamp: Date = Date(),
        caption: String? = nil
    ) {
        self.id = id
        self.fileName = fileName
        self.ownerId = ownerId
        self.timestamp = timestamp
        self.caption = caption
    }
    
    public func absolutePath(in directory: URL) -> URL {
        directory.appendingPathComponent(fileName)
    }
}
