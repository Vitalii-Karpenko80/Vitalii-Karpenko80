import Foundation

public protocol PDFExportable {
    func makeAct(phase: String) -> PDFDocumentModel
    func makeComparison() -> PDFDocumentModel
}

public struct PDFDocumentModel: Sendable {
    public let title: String
    public let subtitle: String?
    public let sections: [PDFSection]
    public let footer: String?
    
    public init(
        title: String,
        subtitle: String? = nil,
        sections: [PDFSection],
        footer: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.sections = sections
        self.footer = footer
    }
}

public struct PDFSection: Sendable {
    public let title: String
    public let rows: [PDFRow]
    
    public init(title: String, rows: [PDFRow]) {
        self.title = title
        self.rows = rows
    }
}

public enum PDFRow: Sendable {
    case text(String)
    case keyValue(key: String, value: String)
    case condition(label: String, state: ConditionState)
    case transition(label: String, from: ConditionState, to: ConditionState)
    case photo(path: String, caption: String?)
    case photoComparison(label: String, beforePath: String?, afterPath: String?)
    case signature(partyName: String, path: String)
    case warning(String)
    case divider
}
