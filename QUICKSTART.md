# Voice Pocket - Quick Start Guide

## Быстрый старт для разработчиков

### Минимальные требования

- macOS 13.0+
- Xcode 15.0+
- iOS 17.0+ SDK
- Apple Developer Account (для тестирования на устройстве)

### Первый запуск

1. **Клонируйте репозиторий**
   ```bash
   git clone https://github.com/Vitalii-Karpenko80/voice-pocket.git
   cd voice-pocket
   ```

2. **Создайте Xcode проект**
   
   Так как это Swift Package, вы можете либо:
   
   a) Создать новый iOS App проект в Xcode и добавить файлы из папки `VoicePocket/`
   
   b) Использовать Swift Package Manager напрямую:
   ```bash
   swift build
   ```

3. **Настройте Bundle ID и Team**
   - Откройте проект в Xcode
   - Signing & Capabilities → выберите свой Team
   - Измените Bundle Identifier

4. **Запустите на симуляторе или устройстве**
   ```
   Cmd + R
   ```

### Настройка для реального устройства

1. **Capabilities**
   
   В Xcode перейдите в `Signing & Capabilities` и добавьте:
   - Siri
   - Background Modes (если нужна фоновая запись)

2. **Entitlements**
   
   Убедитесь что включены:
   - App Intents Extension
   - Siri

3. **Widget Extension**
   
   Для Lock Screen Widget создайте отдельный target:
   - File → New → Target → Widget Extension
   - Скопируйте код из `VoicePocketWidget.swift`

### Тестирование

**Распознавание речи** работает только на реальном устройстве!

Симулятор не поддерживает:
- Микрофон
- Speech Recognition
- Action Button

### Структура проекта

```
VoicePocket/
├── App Entry Point
│   └── VoicePocketApp.swift
│
├── Main UI
│   └── ContentView.swift
│
├── Data Models
│   └── Models/Thought.swift
│
├── Services
│   ├── SpeechRecognizer.swift     # Запись и распознавание
│   ├── ThoughtParser.swift        # AI парсинг
│   └── ThoughtManager.swift       # Управление данными
│
├── Extensions
│   ├── VoicePocketWidget.swift    # Lock Screen Widget
│   └── QuickRecordIntent.swift    # App Intents
│
└── Resources
    └── Info.plist                 # Permissions
```

### Кастомизация

#### Изменить цветовую схему

В `ContentView.swift` измените градиенты:

```swift
LinearGradient(
    gradient: Gradient(colors: [
        Color.blue,  // Ваш цвет
        Color.purple // Ваш цвет
    ]),
    ...
)
```

#### Добавить новые ключевые слова для парсинга

В `ThoughtParser.swift`:

```swift
private func extractTask(from text: String) -> String? {
    let taskKeywords = [
        "позвонить", 
        "написать",
        "ваше_слово" // добавьте здесь
    ]
    ...
}
```

#### Изменить язык распознавания

В `SpeechRecognizer.swift`:

```swift
private let speechRecognizer = SFSpeechRecognizer(
    locale: Locale(identifier: "en-US") // Измените на нужный
)
```

### Troubleshooting

**Проблема**: "Speech recognition not available"
- **Решение**: Запустите на реальном устройстве, не на симуляторе

**Проблема**: Не работает микрофон
- **Решение**: Проверьте Info.plist на наличие `NSMicrophoneUsageDescription`

**Проблема**: Widget не появляется
- **Решение**: Убедитесь что Widget Extension правильно настроен как отдельный target

**Проблема**: Reminders не создаются
- **Решение**: Проверьте разрешения в Настройки → Voice Pocket → Напоминания

### Полезные команды

```bash
# Очистить build
swift package clean

# Обновить зависимости
swift package update

# Сгенерировать Xcode проект
swift package generate-xcodeproj

# Запустить тесты
swift test
```

### Дальнейшая разработка

Смотрите [TODO.md](TODO.md) для списка запланированных фич.

### Поддержка

Если у вас возникли проблемы:
1. Проверьте [Issues](https://github.com/Vitalii-Karpenko80/voice-pocket/issues)
2. Создайте новый Issue с описанием проблемы
3. Или напишите мне: [@Vitalii-Karpenko80](https://github.com/Vitalii-Karpenko80)

---

Удачной разработки! 🚀
