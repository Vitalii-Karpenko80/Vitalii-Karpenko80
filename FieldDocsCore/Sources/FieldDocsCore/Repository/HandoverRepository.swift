import Foundation

#if canImport(UIKit)
import UIKit
#endif

public final class HandoverRepository: @unchecked Sendable {
    private let fileManager = FileManager.default
    private let documentsDirectory: URL
    private let casesDirectory: URL
    private let photosDirectory: URL
    private let signaturesDirectory: URL
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    public init() {
        let paths = fileManager.urls(for: .documentDirectory, in: .userDomainMask)
        self.documentsDirectory = paths[0]
        
        self.casesDirectory = documentsDirectory.appendingPathComponent("Cases")
        self.photosDirectory = documentsDirectory.appendingPathComponent("Photos")
        self.signaturesDirectory = documentsDirectory.appendingPathComponent("Signatures")
        
        encoder.dateEncodingStrategy = .iso8601
        decoder.dateDecodingStrategy = .iso8601
        
        createDirectoriesIfNeeded()
    }
    
    private func createDirectoriesIfNeeded() {
        [casesDirectory, photosDirectory, signaturesDirectory].forEach { directory in
            if !fileManager.fileExists(atPath: directory.path) {
                try? fileManager.createDirectory(at: directory, withIntermediateDirectories: true)
            }
        }
    }
    
    public func save(_ handoverCase: HandoverCase) throws {
        let fileURL = casesDirectory.appendingPathComponent("\(handoverCase.id.uuidString).json")
        let data = try encoder.encode(handoverCase)
        try data.write(to: fileURL)
    }
    
    public func load(id: UUID) throws -> HandoverCase {
        let fileURL = casesDirectory.appendingPathComponent("\(id.uuidString).json")
        let data = try Data(contentsOf: fileURL)
        return try decoder.decode(HandoverCase.self, from: data)
    }
    
    public func loadAll() throws -> [HandoverCase] {
        let contents = try fileManager.contentsOfDirectory(at: casesDirectory, includingPropertiesForKeys: [.contentModificationDateKey])
        
        let cases = try contents.compactMap { url -> HandoverCase? in
            guard url.pathExtension == "json" else { return nil }
            let data = try Data(contentsOf: url)
            return try decoder.decode(HandoverCase.self, from: data)
        }
        
        return cases.sorted { $0.project.modifiedAt > $1.project.modifiedAt }
    }
    
    public func delete(id: UUID) throws {
        let fileURL = casesDirectory.appendingPathComponent("\(id.uuidString).json")
        try fileManager.removeItem(at: fileURL)
    }
    
    #if canImport(UIKit)
    public func savePhoto(_ image: UIImage, for ownerId: UUID) throws -> Photo {
        let photoId = UUID()
        let fileName = "\(photoId.uuidString).jpg"
        let fileURL = photosDirectory.appendingPathComponent(fileName)
        
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            throw RepositoryError.imageConversionFailed
        }
        
        try data.write(to: fileURL)
        
        return Photo(
            id: photoId,
            fileName: fileName,
            ownerId: ownerId,
            timestamp: Date()
        )
    }
    
    public func loadPhoto(_ photo: Photo) -> UIImage? {
        let fileURL = photosDirectory.appendingPathComponent(photo.fileName)
        return UIImage(contentsOfFile: fileURL.path)
    }
    
    public func saveSignature(_ image: UIImage, for partyId: UUID) throws -> Signature {
        let signatureId = UUID()
        let fileName = "\(signatureId.uuidString).png"
        let fileURL = signaturesDirectory.appendingPathComponent(fileName)
        
        guard let data = image.pngData() else {
            throw RepositoryError.imageConversionFailed
        }
        
        try data.write(to: fileURL)
        
        return Signature(
            id: signatureId,
            fileName: fileName,
            partyId: partyId,
            timestamp: Date()
        )
    }
    
    public func loadSignature(_ signature: Signature) -> UIImage? {
        let fileURL = signaturesDirectory.appendingPathComponent(signature.fileName)
        return UIImage(contentsOfFile: fileURL.path)
    }
    #endif
    
    public func deletePhoto(_ photo: Photo) throws {
        let fileURL = photosDirectory.appendingPathComponent(photo.fileName)
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }
    
    public func deleteSignature(_ signature: Signature) throws {
        let fileURL = signaturesDirectory.appendingPathComponent(signature.fileName)
        if fileManager.fileExists(atPath: fileURL.path) {
            try fileManager.removeItem(at: fileURL)
        }
    }
    
    public func getPhotoPath(_ photo: Photo) -> String {
        photosDirectory.appendingPathComponent(photo.fileName).path
    }
    
    public func getSignaturePath(_ signature: Signature) -> String {
        signaturesDirectory.appendingPathComponent(signature.fileName).path
    }
}

public enum RepositoryError: Error {
    case imageConversionFailed
    case fileNotFound
}
