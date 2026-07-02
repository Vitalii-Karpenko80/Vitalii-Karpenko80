import Foundation

extension HandoverCase: PDFExportable {
    public func makeAct(phase: String) -> PDFDocumentModel {
        let isMoveIn = phase == "moveIn"
        let phaseTitle = isMoveIn ? "Заселение" : "Выселение"
        let date = isMoveIn ? moveInMeta.completedAt : moveOutMeta.completedAt
        let meterReadings = isMoveIn ? moveInMeta.meterReadings : moveOutMeta.meterReadings
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .short
        dateFormatter.locale = Locale(identifier: "ru_RU")
        
        let dateString = date.map { dateFormatter.string(from: $0) } ?? "Не указана"
        
        var sections: [PDFSection] = []
        
        let objectSection = PDFSection(
            title: "Объект",
            rows: [
                .keyValue(key: "Название", value: project.name),
                .keyValue(key: "Адрес", value: project.address),
                .keyValue(key: "Дата осмотра", value: dateString)
            ]
        )
        sections.append(objectSection)
        
        let landlordRows: [PDFRow] = [
            .keyValue(key: "ФИО", value: landlord.fullName),
            .keyValue(key: "ИИН", value: landlord.iin),
            .keyValue(key: "Телефон", value: landlord.phone)
        ]
        sections.append(PDFSection(title: "Арендодатель", rows: landlordRows))
        
        let tenantRows: [PDFRow] = [
            .keyValue(key: "ФИО", value: tenant.fullName),
            .keyValue(key: "ИИН", value: tenant.iin),
            .keyValue(key: "Телефон", value: tenant.phone)
        ]
        sections.append(PDFSection(title: "Арендатор", rows: tenantRows))
        
        let depositFormatted = MSCurrency.format(depositAmount)
        sections.append(PDFSection(title: "Залог", rows: [
            .keyValue(key: "Сумма", value: depositFormatted)
        ]))
        
        for room in rooms {
            var roomRows: [PDFRow] = []
            
            for element in room.elements {
                let condition = isMoveIn ? element.moveIn : element.moveOut
                if let condition = condition {
                    roomRows.append(.condition(label: element.name, state: condition.state))
                    
                    if !condition.note.isEmpty {
                        roomRows.append(.text("  Заметка: \(condition.note)"))
                    }
                    
                    for photoId in condition.photoIds {
                        if let photo = photos[photoId] {
                            let photoPath = photo.fileName
                            roomRows.append(.photo(path: photoPath, caption: photo.caption))
                        }
                    }
                }
            }
            
            if !roomRows.isEmpty {
                sections.append(PDFSection(title: room.name, rows: roomRows))
            }
        }
        
        let meterRows: [PDFRow] = [
            .keyValue(key: "Электричество", value: meterReadings.electricity),
            .keyValue(key: "Холодная вода", value: meterReadings.coldWater),
            .keyValue(key: "Горячая вода", value: meterReadings.hotWater),
            .keyValue(key: "Газ", value: meterReadings.gas)
        ]
        sections.append(PDFSection(title: "Показания счётчиков", rows: meterRows))
        
        let signatures = isMoveIn ? moveInSignatures : moveOutSignatures
        var signatureRows: [PDFRow] = []
        
        if let landlordSig = signatures[landlord.id] {
            signatureRows.append(.signature(partyName: landlord.fullName, path: landlordSig.fileName))
        }
        
        if let tenantSig = signatures[tenant.id] {
            signatureRows.append(.signature(partyName: tenant.fullName, path: tenantSig.fileName))
        }
        
        if !signatureRows.isEmpty {
            sections.append(PDFSection(title: "Подписи", rows: signatureRows))
        }
        
        return PDFDocumentModel(
            title: "Акт приёма-передачи квартиры",
            subtitle: "\(phaseTitle) • \(project.address)",
            sections: sections,
            footer: "Создано в Handover KZ • \(dateString)"
        )
    }
    
    public func makeComparison() -> PDFDocumentModel {
        guard canAccessComparison else {
            return PDFDocumentModel(
                title: "Сравнение недоступно",
                subtitle: "Необходимо завершить обе фазы",
                sections: [],
                footer: nil
            )
        }
        
        var sections: [PDFSection] = []
        
        let objectSection = PDFSection(
            title: "Объект",
            rows: [
                .keyValue(key: "Название", value: project.name),
                .keyValue(key: "Адрес", value: project.address)
            ]
        )
        sections.append(objectSection)
        
        for room in rooms {
            var roomRows: [PDFRow] = []
            
            for element in room.elements {
                if let moveIn = element.moveIn, let moveOut = element.moveOut {
                    roomRows.append(.transition(
                        label: element.name,
                        from: moveIn.state,
                        to: moveOut.state
                    ))
                    
                    if element.isDeteriorated {
                        if !moveOut.note.isEmpty {
                            roomRows.append(.text("  Примечание: \(moveOut.note)"))
                        }
                    }
                    
                    let moveInPhoto = moveIn.photoIds.first.flatMap { photos[$0] }
                    let moveOutPhoto = moveOut.photoIds.first.flatMap { photos[$0] }
                    
                    if moveInPhoto != nil || moveOutPhoto != nil {
                        roomRows.append(.photoComparison(
                            label: element.name,
                            beforePath: moveInPhoto?.fileName,
                            afterPath: moveOutPhoto?.fileName
                        ))
                    }
                }
            }
            
            if !roomRows.isEmpty {
                sections.append(PDFSection(title: room.name, rows: roomRows))
            }
        }
        
        if hasDeteriorations {
            var deductionRows: [PDFRow] = []
            deductionRows.append(.warning("Обнаружены ухудшения состояния"))
            
            for (room, elements) in deterioratedElements {
                deductionRows.append(.divider)
                deductionRows.append(.text("\(room.name):"))
                for element in elements {
                    if let moveIn = element.moveIn, let moveOut = element.moveOut {
                        deductionRows.append(.transition(
                            label: "  • \(element.name)",
                            from: moveIn.state,
                            to: moveOut.state
                        ))
                    }
                }
            }
            
            sections.append(PDFSection(title: "К удержанию из залога", rows: deductionRows))
        } else {
            sections.append(PDFSection(
                title: "Итог",
                rows: [.text("Ухудшений не обнаружено. Залог подлежит возврату в полном объёме.")]
            ))
        }
        
        return PDFDocumentModel(
            title: "Сравнение состояния квартиры",
            subtitle: project.address,
            sections: sections,
            footer: "Создано в Handover KZ"
        )
    }
}

public struct MSCurrency {
    public static func format(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.groupingSeparator = " "
        formatter.decimalSeparator = ","
        formatter.maximumFractionDigits = 2
        formatter.minimumFractionDigits = 0
        
        let amountString = formatter.string(from: amount as NSDecimalNumber) ?? "\(amount)"
        return "\(amountString) ₸"
    }
}
