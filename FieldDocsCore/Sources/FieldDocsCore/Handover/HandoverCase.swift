import Foundation

public struct PhaseMeta: Codable, Sendable {
    public var isCompleted: Bool
    public var completedAt: Date?
    public var meterReadings: MeterReadings
    
    public init(
        isCompleted: Bool = false,
        completedAt: Date? = nil,
        meterReadings: MeterReadings = MeterReadings()
    ) {
        self.isCompleted = isCompleted
        self.completedAt = completedAt
        self.meterReadings = meterReadings
    }
}

public struct MeterReadings: Codable, Sendable {
    public var electricity: String
    public var coldWater: String
    public var hotWater: String
    public var gas: String
    
    public init(
        electricity: String = "",
        coldWater: String = "",
        hotWater: String = "",
        gas: String = ""
    ) {
        self.electricity = electricity
        self.coldWater = coldWater
        self.hotWater = hotWater
        self.gas = gas
    }
}

public struct HandoverCase: Codable, Identifiable, Sendable {
    public let id: UUID
    public var project: Project
    public var landlord: Party
    public var tenant: Party
    public var depositAmount: Decimal
    public var rooms: [HandoverRoom]
    public var moveInMeta: PhaseMeta
    public var moveOutMeta: PhaseMeta
    public var moveInSignatures: [UUID: Signature]
    public var moveOutSignatures: [UUID: Signature]
    public var photos: [UUID: Photo]
    
    public init(
        id: UUID = UUID(),
        project: Project,
        landlord: Party = Party(),
        tenant: Party = Party(),
        depositAmount: Decimal = 0,
        rooms: [HandoverRoom] = [],
        moveInMeta: PhaseMeta = PhaseMeta(),
        moveOutMeta: PhaseMeta = PhaseMeta(),
        moveInSignatures: [UUID: Signature] = [:],
        moveOutSignatures: [UUID: Signature] = [:],
        photos: [UUID: Photo] = [:]
    ) {
        self.id = id
        self.project = project
        self.landlord = landlord
        self.tenant = tenant
        self.depositAmount = depositAmount
        self.rooms = rooms
        self.moveInMeta = moveInMeta
        self.moveOutMeta = moveOutMeta
        self.moveInSignatures = moveInSignatures
        self.moveOutSignatures = moveOutSignatures
        self.photos = photos
    }
    
    public enum Phase {
        case moveIn
        case moveOut
    }
    
    public var canAccessMoveOut: Bool {
        moveInMeta.isCompleted
    }
    
    public var canAccessComparison: Bool {
        moveInMeta.isCompleted && moveOutMeta.isCompleted
    }
    
    public var deterioratedElements: [(room: HandoverRoom, elements: [HandoverElement])] {
        rooms.compactMap { room in
            let deteriorated = room.deterioratedElements
            return deteriorated.isEmpty ? nil : (room, deteriorated)
        }
    }
    
    public var hasDeteriorations: Bool {
        !deterioratedElements.isEmpty
    }
}
