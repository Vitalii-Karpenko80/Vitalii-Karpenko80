import Foundation

#if canImport(UIKit)
import UIKit

public final class PDFRenderer: @unchecked Sendable {
    private let pageWidth: CGFloat = 595.2
    private let pageHeight: CGFloat = 841.8
    private let margin: CGFloat = 40
    
    public init() {}
    
    public func render(_ document: PDFDocumentModel) -> Data {
        let pdfMetaData = [
            kCGPDFContextCreator: "Handover KZ",
            kCGPDFContextAuthor: "Handover KZ App",
            kCGPDFContextTitle: document.title
        ]
        
        let format = UIGraphicsPDFRendererFormat()
        format.documentInfo = pdfMetaData as [String: Any]
        
        let pageRect = CGRect(x: 0, y: 0, width: pageWidth, height: pageHeight)
        let renderer = UIGraphicsPDFRenderer(bounds: pageRect, format: format)
        
        let data = renderer.pdfData { context in
            var yOffset: CGFloat = margin
            
            context.beginPage()
            
            yOffset = drawTitle(document.title, at: yOffset, in: context)
            
            if let subtitle = document.subtitle {
                yOffset = drawSubtitle(subtitle, at: yOffset, in: context)
            }
            
            yOffset += 20
            
            for section in document.sections {
                if yOffset > pageHeight - margin - 100 {
                    context.beginPage()
                    yOffset = margin
                }
                
                yOffset = drawSection(section, at: yOffset, in: context)
            }
            
            if let footer = document.footer {
                drawFooter(footer, in: context)
            }
        }
        
        return data
    }
    
    private func drawTitle(_ title: String, at y: CGFloat, in context: UIGraphicsPDFRendererContext) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 24),
            .foregroundColor: UIColor.black
        ]
        
        let attributedString = NSAttributedString(string: title, attributes: attributes)
        let rect = CGRect(x: margin, y: y, width: pageWidth - 2 * margin, height: 40)
        attributedString.draw(in: rect)
        
        return y + 50
    }
    
    private func drawSubtitle(_ subtitle: String, at y: CGFloat, in context: UIGraphicsPDFRendererContext) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 14),
            .foregroundColor: UIColor.darkGray
        ]
        
        let attributedString = NSAttributedString(string: subtitle, attributes: attributes)
        let rect = CGRect(x: margin, y: y, width: pageWidth - 2 * margin, height: 30)
        attributedString.draw(in: rect)
        
        return y + 40
    }
    
    private func drawSection(_ section: PDFSection, at y: CGFloat, in context: UIGraphicsPDFRendererContext) -> CGFloat {
        var currentY = y
        
        let titleAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.black
        ]
        
        let titleString = NSAttributedString(string: section.title, attributes: titleAttributes)
        let titleRect = CGRect(x: margin, y: currentY, width: pageWidth - 2 * margin, height: 30)
        titleString.draw(in: titleRect)
        currentY += 40
        
        for row in section.rows {
            currentY = drawRow(row, at: currentY, in: context)
        }
        
        return currentY + 20
    }
    
    private func drawRow(_ row: PDFRow, at y: CGFloat, in context: UIGraphicsPDFRendererContext) -> CGFloat {
        switch row {
        case .text(let text):
            return drawText(text, at: y, in: context)
            
        case .keyValue(let key, let value):
            return drawKeyValue(key: key, value: value, at: y, in: context)
            
        case .condition(let label, let state):
            return drawCondition(label: label, state: state, at: y, in: context)
            
        case .transition(let label, let from, let to):
            return drawTransition(label: label, from: from, to: to, at: y, in: context)
            
        case .photo(let path, let caption):
            return drawPhoto(path: path, caption: caption, at: y, in: context)
            
        case .photoComparison(let label, let beforePath, let afterPath):
            return drawPhotoComparison(label: label, beforePath: beforePath, afterPath: afterPath, at: y, in: context)
            
        case .signature(let partyName, let path):
            return drawSignature(partyName: partyName, path: path, at: y, in: context)
            
        case .warning(let message):
            return drawWarning(message, at: y, in: context)
            
        case .divider:
            return drawDivider(at: y, in: context)
        }
    }
    
    private func drawText(_ text: String, at y: CGFloat, in context: UIGraphicsPDFRendererContext) -> CGFloat {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ]
        
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let rect = CGRect(x: margin, y: y, width: pageWidth - 2 * margin, height: 20)
        attributedString.draw(in: rect)
        
        return y + 25
    }
    
    private func drawKeyValue(key: String, value: String, at y: CGFloat, in context: UIGraphicsPDFRendererContext) -> CGFloat {
        let keyAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ]
        
        let valueAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.darkGray
        ]
        
        let keyString = NSAttributedString(string: "\(key): ", attributes: keyAttributes)
        let valueString = NSAttributedString(string: value, attributes: valueAttributes)
        
        let combined = NSMutableAttributedString()
        combined.append(keyString)
        combined.append(valueString)
        
        let rect = CGRect(x: margin, y: y, width: pageWidth - 2 * margin, height: 20)
        combined.draw(in: rect)
        
        return y + 25
    }
    
    private func drawCondition(label: String, state: ConditionState, at y: CGFloat, in context: UIGraphicsPDFRendererContext) -> CGFloat {
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ]
        
        let labelString = NSAttributedString(string: "\(label): ", attributes: labelAttributes)
        let labelRect = CGRect(x: margin, y: y, width: 200, height: 20)
        labelString.draw(in: labelRect)
        
        let badgeRect = CGRect(x: margin + 210, y: y, width: 100, height: 20)
        context.cgContext.setFillColor(hexToColor(state.color).cgColor)
        context.cgContext.fillEllipse(in: badgeRect)
        
        let stateAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 10),
            .foregroundColor: UIColor.white
        ]
        let stateString = NSAttributedString(string: state.localizedName, attributes: stateAttributes)
        stateString.draw(in: badgeRect)
        
        return y + 30
    }
    
    private func drawTransition(label: String, from: ConditionState, to: ConditionState, at y: CGFloat, in context: UIGraphicsPDFRendererContext) -> CGFloat {
        let text = "\(label): \(from.localizedName) → \(to.localizedName)"
        let isDeterioration = to.isDeterioratedFrom(from)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: isDeterioration ? UIColor.red : UIColor.black
        ]
        
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let rect = CGRect(x: margin, y: y, width: pageWidth - 2 * margin, height: 20)
        attributedString.draw(in: rect)
        
        if isDeterioration {
            let warningIcon = "⚠️"
            let iconAttributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.systemFont(ofSize: 14)
            ]
            let iconString = NSAttributedString(string: warningIcon, attributes: iconAttributes)
            iconString.draw(at: CGPoint(x: margin - 25, y: y))
        }
        
        return y + 25
    }
    
    private func drawPhoto(path: String, caption: String?, at y: CGFloat, in context: UIGraphicsPDFRendererContext) -> CGFloat {
        var currentY = y
        
        if let image = UIImage(contentsOfFile: path) {
            let maxWidth: CGFloat = pageWidth - 2 * margin
            let maxHeight: CGFloat = 200
            let imageSize = image.size
            let aspectRatio = imageSize.width / imageSize.height
            
            var drawWidth = maxWidth
            var drawHeight = maxWidth / aspectRatio
            
            if drawHeight > maxHeight {
                drawHeight = maxHeight
                drawWidth = maxHeight * aspectRatio
            }
            
            let imageRect = CGRect(x: margin, y: currentY, width: drawWidth, height: drawHeight)
            image.draw(in: imageRect)
            currentY += drawHeight + 10
        }
        
        if let caption = caption {
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont.italicSystemFont(ofSize: 10),
                .foregroundColor: UIColor.darkGray
            ]
            let captionString = NSAttributedString(string: caption, attributes: attributes)
            let captionRect = CGRect(x: margin, y: currentY, width: pageWidth - 2 * margin, height: 20)
            captionString.draw(in: captionRect)
            currentY += 25
        }
        
        return currentY
    }
    
    private func drawPhotoComparison(label: String, beforePath: String?, afterPath: String?, at y: CGFloat, in context: UIGraphicsPDFRendererContext) -> CGFloat {
        var currentY = y
        
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ]
        let labelString = NSAttributedString(string: label, attributes: labelAttributes)
        let labelRect = CGRect(x: margin, y: currentY, width: pageWidth - 2 * margin, height: 20)
        labelString.draw(in: labelRect)
        currentY += 25
        
        let photoWidth = (pageWidth - 2 * margin - 20) / 2
        let photoHeight: CGFloat = 150
        
        if let beforePath = beforePath, let beforeImage = UIImage(contentsOfFile: beforePath) {
            let beforeRect = CGRect(x: margin, y: currentY, width: photoWidth, height: photoHeight)
            beforeImage.draw(in: beforeRect)
            
            let beforeLabel = NSAttributedString(string: "До", attributes: [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.darkGray
            ])
            beforeLabel.draw(at: CGPoint(x: margin, y: currentY + photoHeight + 5))
        }
        
        if let afterPath = afterPath, let afterImage = UIImage(contentsOfFile: afterPath) {
            let afterRect = CGRect(x: margin + photoWidth + 20, y: currentY, width: photoWidth, height: photoHeight)
            afterImage.draw(in: afterRect)
            
            let afterLabel = NSAttributedString(string: "После", attributes: [
                .font: UIFont.systemFont(ofSize: 10),
                .foregroundColor: UIColor.darkGray
            ])
            afterLabel.draw(at: CGPoint(x: margin + photoWidth + 20, y: currentY + photoHeight + 5))
        }
        
        return currentY + photoHeight + 30
    }
    
    private func drawSignature(partyName: String, path: String, at y: CGFloat, in context: UIGraphicsPDFRendererContext) -> CGFloat {
        var currentY = y
        
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 12),
            .foregroundColor: UIColor.black
        ]
        let labelString = NSAttributedString(string: "Подпись \(partyName):", attributes: labelAttributes)
        let labelRect = CGRect(x: margin, y: currentY, width: pageWidth - 2 * margin, height: 20)
        labelString.draw(in: labelRect)
        currentY += 25
        
        if let image = UIImage(contentsOfFile: path) {
            let signatureRect = CGRect(x: margin, y: currentY, width: 200, height: 100)
            
            context.cgContext.setStrokeColor(UIColor.lightGray.cgColor)
            context.cgContext.stroke(signatureRect)
            
            image.draw(in: signatureRect)
            currentY += 110
        }
        
        return currentY
    }
    
    private func drawWarning(_ message: String, at y: CGFloat, in context: UIGraphicsPDFRendererContext) -> CGFloat {
        let warningRect = CGRect(x: margin, y: y, width: pageWidth - 2 * margin, height: 40)
        
        context.cgContext.setFillColor(UIColor(red: 1.0, green: 0.95, blue: 0.8, alpha: 1.0).cgColor)
        context.cgContext.fill(warningRect)
        
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.boldSystemFont(ofSize: 12),
            .foregroundColor: UIColor(red: 0.8, green: 0.4, blue: 0.0, alpha: 1.0)
        ]
        
        let text = "⚠️ \(message)"
        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let textRect = CGRect(x: margin + 10, y: y + 10, width: pageWidth - 2 * margin - 20, height: 20)
        attributedString.draw(in: textRect)
        
        return y + 50
    }
    
    private func drawDivider(at y: CGFloat, in context: UIGraphicsPDFRendererContext) -> CGFloat {
        context.cgContext.setStrokeColor(UIColor.lightGray.cgColor)
        context.cgContext.setLineWidth(1)
        context.cgContext.move(to: CGPoint(x: margin, y: y))
        context.cgContext.addLine(to: CGPoint(x: pageWidth - margin, y: y))
        context.cgContext.strokePath()
        
        return y + 10
    }
    
    private func drawFooter(_ footer: String, in context: UIGraphicsPDFRendererContext) {
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.systemFont(ofSize: 10),
            .foregroundColor: UIColor.darkGray
        ]
        
        let attributedString = NSAttributedString(string: footer, attributes: attributes)
        let rect = CGRect(x: margin, y: pageHeight - margin, width: pageWidth - 2 * margin, height: 20)
        attributedString.draw(in: rect)
    }
    
    private func hexToColor(_ hex: String) -> UIColor {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
    }
}
#endif
