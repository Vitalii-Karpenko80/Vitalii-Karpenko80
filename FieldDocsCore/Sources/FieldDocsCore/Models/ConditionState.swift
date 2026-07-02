import Foundation

public enum ConditionState: String, Codable, CaseIterable, Comparable {
    case excellent
    case good
    case fair
    case damaged
    
    public var rank: Int {
        switch self {
        case .excellent: return 3
        case .good: return 2
        case .fair: return 1
        case .damaged: return 0
        }
    }
    
    public var localizedName: String {
        switch self {
        case .excellent: return NSLocalizedString("condition.excellent", value: "Отлично", comment: "")
        case .good: return NSLocalizedString("condition.good", value: "Норма", comment: "")
        case .fair: return NSLocalizedString("condition.fair", value: "Удовлетворительно", comment: "")
        case .damaged: return NSLocalizedString("condition.damaged", value: "Повреждено", comment: "")
        }
    }
    
    public var color: String {
        switch self {
        case .excellent: return "#00C851"
        case .good: return "#4CAF50"
        case .fair: return "#FFA000"
        case .damaged: return "#F44336"
        }
    }
    
    public static func < (lhs: ConditionState, rhs: ConditionState) -> Bool {
        lhs.rank < rhs.rank
    }
    
    public func isDeterioratedFrom(_ previous: ConditionState) -> Bool {
        self.rank < previous.rank
    }
}
