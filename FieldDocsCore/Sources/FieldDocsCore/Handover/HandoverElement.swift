import Foundation

public struct ElementCondition: Codable, Sendable {
    public var state: ConditionState
    public var note: String
    public var photoIds: [UUID]
    
    public init(
        state: ConditionState = .good,
        note: String = "",
        photoIds: [UUID] = []
    ) {
        self.state = state
        self.note = note
        self.photoIds = photoIds
    }
}

public struct HandoverElement: Codable, Identifiable, Sendable {
    public let id: UUID
    public var name: String
    public var moveIn: ElementCondition?
    public var moveOut: ElementCondition?
    
    public init(
        id: UUID = UUID(),
        name: String,
        moveIn: ElementCondition? = nil,
        moveOut: ElementCondition? = nil
    ) {
        self.id = id
        self.name = name
        self.moveIn = moveIn
        self.moveOut = moveOut
    }
    
    public var isDeteriorated: Bool {
        guard let moveIn = moveIn, let moveOut = moveOut else {
            return false
        }
        return moveOut.state.isDeterioratedFrom(moveIn.state)
    }
}

public struct HandoverRoom: Codable, Identifiable, Sendable {
    public let id: UUID
    public var name: String
    public var elements: [HandoverElement]
    
    public init(
        id: UUID = UUID(),
        name: String,
        elements: [HandoverElement] = []
    ) {
        self.id = id
        self.name = name
        self.elements = elements
    }
    
    public var deterioratedElements: [HandoverElement] {
        elements.filter { $0.isDeteriorated }
    }
}
