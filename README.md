# Voice Pocket 🎤  
### Голосовой «входящий ящик» для мыслей  
*iOS 2026 Design Language Edition*

> Современное iOS приложение с **Liquid Glass UI**, **springy animations** и **AI-powered парсингом** задач из речи

![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![Design](https://img.shields.io/badge/Design-iOS%202026-purple.svg)

---

## ✨ Особенности

### 🎯 Функциональность
- **Мгновенная запись**: Одна кнопка на Lock Screen или Action Button
- **Гибридный парсинг**: Локальный парсер + опциональный GPT-4
- **GPT-4 интеграция**: Улучшенное извлечение задач, дат и контекста
- **Интеграция с Reminders**: Задачи автоматически сохраняются в системные напоминания
- **Поддержка русского языка**: Распознавание речи настроено на русский
- **Lock Screen Widget**: Быстрый доступ прямо с экрана блокировки
- **Приоритеты и типы**: Автоматическое определение приоритета и категории задачи

### 🎨 Дизайн iOS 2026

#### Liquid Glass UI
Самый актуальный тренд от Apple — адаптивная материальная система с эффектами преломления света:
- **Glassmorphism cards** с размытием и прозрачностью
- **Soft depth shadows** для тактильности
- **Border shimmer** эффекты
- **Dynamic blur** в зависимости от контента

#### Springy Animations
Физически основанные анимации с spring physics:
- **Natural motion** при переходах
- **Bounce effects** для интерактивных элементов
- **Scale transformations** при нажатиях
- **Haptic feedback** синхронизированный с анимациями

#### Modern Color System
Продуманная цветовая палитра 2026:
- **Cyber Blue** (`#66CCFF`) — основной акцент
- **Purple** (`#CC66FF`) — вторичный акцент
- **Pink** (`#FF80B3`) — третичный акцент
- **Liquid Background** — глубокий градиент
- **Animated gradients** — плавно меняющиеся фоны

#### Typography & Spacing
San Francisco Rounded с улучшенным spacing:
- **Display font** для заголовков (48pt, bold)
- **Title fonts** (32pt / 24pt, semibold)
- **Body font** (17pt, regular)
- **Generous line spacing** (4-6pt)
- **Consistent padding** (20-24pt)

#### Micro-interactions
Продуманные детали взаимодействия:
- **Pulsing effects** при записи
- **Symbol effects** SF Symbols
- **Smooth transitions** между состояниями
- **Interactive feedback** на каждое действие

---

## 📋 Требования

- **iOS 17.0** или новее
- **iPhone** с поддержкой Speech Recognition
- **Xcode 15.0+** для разработки
- Доступ к микрофону, распознаванию речи и напоминаниям

---

## 🚀 Установка

### 1. Клонирование репозитория

```bash
git clone https://github.com/Vitalii-Karpenko80/voice-pocket.git
cd voice-pocket
```

### 2. Открытие в Xcode

```bash
open VoicePocket.xcodeproj
```

Или используйте Swift Package Manager:

```bash
swift build
```

### 3. Настройка Bundle Identifier

1. Откройте проект в Xcode
2. Выберите target `VoicePocket`
3. В разделе **Signing & Capabilities** укажите свой Team
4. Измените Bundle Identifier на уникальный

### 4. Разрешения

Приложение запросит следующие разрешения при первом запуске:
- ✅ **Микрофон**: Для записи голоса
- ✅ **Распознавание речи**: Для преобразования речи в текст
- ✅ **Напоминания**: Для создания задач
- ✅ **Календарь**: Для добавления событий (опционально)

---

## 💡 Использование

### Базовый режим

1. Откройте приложение
2. Нажмите большую круглую кнопку с микрофоном
3. Произнесите свою мысль:
   
   > "Завтра позвонить Сергею насчёт дверей, он обещал цену до 12 часов"

4. Нажмите "Сохранить"

**Результат:**
```
✓ Задача: "позвонить Сергею"
✓ Тема: "дверей"  
✓ Когда: Завтра, 12:00
✓ Контекст: "он обещал цену до 12 часов"
✓ Приоритет: high 🔴
✓ Тип: call 📞
```

### Lock Screen Widget

1. Долгое нажатие на Lock Screen
2. Нажмите "Customize"
3. Добавьте Voice Pocket widget
4. Теперь можно записывать мысли прямо с экрана блокировки!

### Action Button (iPhone 15 Pro/Pro Max)

1. Откройте **Настройки → Action Button**
2. Выберите **Shortcut**
3. Выберите "Быстрая запись мысли"
4. Готово! Action Button мгновенно открывает Voice Pocket

### Siri Shortcuts

Скажите Siri:
- "Записать мысль в Voice Pocket"
- "Открыть Voice Pocket"
- "Новая заметка в Voice Pocket"

---

## 🏗 Архитектура

```
VoicePocket/
├── VoicePocketApp.swift          # Entry point приложения
│
├── Models/
│   └── Thought.swift             # Модель мысли/задачи
│
├── Services/
│   ├── SpeechRecognizer.swift    # Speech Recognition API
│   ├── ThoughtParser.swift       # Локальный парсер
│   ├── GPT4ParsingService.swift  # 🧠 GPT-4 парсер
│   └── ThoughtManager.swift      # Менеджер данных + EventKit
│
├── Views/
│   ├── ContentView.swift         # Главный экран
│   ├── SettingsView.swift        # ⚙️ Настройки и API ключ
│   └── DesignSystem.swift        # Дизайн-система iOS 2026
│
├── VoicePocketWidget.swift       # Lock Screen Widget
├── QuickRecordIntent.swift       # App Intents
├── PreviewHelper.swift           # Preview helpers
│
└── Resources/
    └── Info.plist                # Разрешения и конфигурация
```

---

## 🎨 Дизайн-система

### Компоненты

#### LiquidGlassCard
```swift
.liquidGlassCard(
    tintColor: .glassTint,
    cornerRadius: 24
)
```

#### SpringyButton
```swift
.springyButton(scale: 0.95)
```

#### SoftDepthShadow
```swift
.softDepthShadow(
    color: .accentPrimary,
    radius: 30
)
```

#### PulsingEffect
```swift
.pulsing(color: .accentPrimary)
```

#### AnimatedGradientBackground
```swift
AnimatedGradientBackground()
```

### Цвета

```swift
Color.accentPrimary        // Cyber Blue #66CCFF
Color.accentSecondary      // Purple #CC66FF
Color.accentTertiary       // Pink #FF80B3
Color.liquidBackground     // Deep Dark #0D0D1F
Color.glassTint            // White 5% opacity
Color.glassBorder          // White 15% opacity
Color.textPrimary          // White 100%
Color.textSecondary        // White 70%
Color.textTertiary         // White 40%
```

### Типографика

```swift
Font.display(48)           // Bold Rounded
Font.title1(32)            // Semibold Rounded
Font.title2(24)            // Semibold Rounded
Font.body(17)              // Regular Rounded
Font.caption(13)           // Medium Rounded
```

---

## 🧩 Технологии

- **SwiftUI** — Декларативный UI фреймворк
- **Speech Framework** — Распознавание речи
- **OpenAI GPT-4o** — Умный парсинг задач
- **AVFoundation** — Работа с аудио
- **EventKit** — Интеграция с Reminders и Calendar
- **WidgetKit** — Lock Screen Widgets
- **App Intents** — Action Button и Shortcuts
- **NaturalLanguage** — Обработка естественного языка

---

## 🎯 Примеры использования

### Пример 1: Звонок
```
Пользователь: "Завтра в 9 утра встретиться с Машей насчёт проекта"

Voice Pocket распознает:
├─ Задача: "встретиться с Машей"
├─ Тема: "проекта"
├─ Когда: Завтра, 09:00
└─ Контекст: —
```

### Пример 2: Покупки
```
Пользователь: "Купить молоко и хлеб сегодня, не забыть"

Voice Pocket распознает:
├─ Задача: "Купить молоко и хлеб"
├─ Когда: Сегодня
└─ Контекст: "не забыть"
```

### Пример 3: Отчёт
```
Пользователь: "Послезавтра написать отчёт о продажах, срочно, дедлайн до конца недели"

Voice Pocket распознает:
├─ Задача: "написать отчёт"
├─ Тема: "продажах"
├─ Когда: Послезавтра
└─ Контекст: "срочно, дедлайн до конца недели"
```

---

## 🎯 Roadmap

### v1.1
- [ ] Поддержка английского языка
- [ ] Улучшенный парсинг с GPT-4
- [ ] iCloud синхронизация
- [ ] История редактирования

### v1.2
- [ ] Apple Watch приложение
- [ ] macOS версия
- [ ] Теги и категории
- [ ] Поиск и фильтры

### v1.3
- [ ] Экспорт в Notion, Todoist, Things
- [ ] Повторяющиеся задачи
- [ ] Геолокация для напоминаний
- [ ] Статистика и аналитика

---

## 🐛 Известные проблемы

- Парсинг времени работает только для форматов "до/в/к HH:MM"
- Нет поддержки повторяющихся задач
- Контекст извлекается только по ключевым словам
- Симулятор не поддерживает Speech Recognition (только реальное устройство)

---

## 🤝 Вклад

Contributions приветствуются! 

1. Fork репозитория
2. Создайте feature branch  
   ```bash
   git checkout -b feature/amazing-feature
   ```
3. Commit изменения  
   ```bash
   git commit -m 'Add amazing feature'
   ```
4. Push в branch  
   ```bash
   git push origin feature/amazing-feature
   ```
5. Откройте Pull Request

---

## 📄 Лицензия

MIT License — см. файл [LICENSE](LICENSE)

---

## 👨‍💻 Автор

**Виталий Карпенко**  
[GitHub](https://github.com/Vitalii-Karpenko80)

---

## 🙏 Благодарности

- Apple за вдохновляющие фреймворки Speech и EventKit
- iOS дизайн-сообществу за тренды 2026
- Всем контрибьюторам проекта

---

## 📸 Скриншоты

_Скриншоты будут добавлены после тестирования на устройстве_

---

**Сделано с ❤️ для продуктивности | iOS 2026 Design Language**
