# Mindy 🧠  
### Your AI Thought Companion  
*iOS 2026 Design Language Edition with GPT-4*

> Голосовой AI-помощник с **Liquid Glass UI**, **springy animations** и **GPT-4 powered** парсингом задач

![iOS](https://img.shields.io/badge/iOS-17.0+-blue.svg)
![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)
![Design](https://img.shields.io/badge/Design-iOS%202026-purple.svg)
![AI](https://img.shields.io/badge/AI-GPT--4-green.svg)

---

## 💡 Что такое Mindy?

**Mindy** — это ваш персональный разум-помощник, который никогда не забывает. Просто скажите, что у вас на уме, и Mindy:

- 🎯 **Извлечёт задачу** из вашей речи
- 📅 **Распознает дату и время** в любом формате  
- 🎨 **Определит приоритет** автоматически
- 🏷️ **Категоризирует** по типу действия
- ✅ **Создаст напоминание** в системе

**Всё это — одним нажатием кнопки.**

---

## ✨ Почему Mindy?

### 🧠 Понимает контекст
```
Вы говорите: "К пятнице обязательно закончить отчёт о Q3 
продажах, это критично для встречи с инвесторами"

Mindy распознает:
✓ Задача: "закончить отчёт"
✓ Тема: "Q3 продажах"  
✓ Когда: Пятница этой недели
✓ Контекст: "критично для встречи с инвесторами"
✓ Приоритет: high 🔴
✓ Тип: task
```

### ⚡ Гибридная обработка

**Двухуровневая система:**
1. **Локальный парсер** — мгновенно, бесплатно, offline
2. **GPT-4 парсер** — умно, точно, понимает нюансы

### 🎨 Современный дизайн iOS 2026

- **Liquid Glass UI** — эффекты преломления света
- **Springy animations** — физически правильные анимации
- **Cyber Blue/Purple** палитра — яркие акценты
- **Micro-interactions** — haptic feedback на каждое действие

---

## 🚀 Основные возможности

### Голосовой ввод
- 🎤 Распознавание речи на русском языке
- 🔴 Live transcription с визуализацией
- 📝 Автоматическое сохранение в текст

### Умный парсинг (GPT-4)
- 🎯 Извлечение задач из речи
- 📅 Любые форматы дат ("завтра", "к пятнице", "через неделю")
- 🔴🟡🟢 Автоматические приоритеты (high/medium/low)
- 📞👥🛒🔔📝✅ Категоризация по типу

### Интеграции
- ✅ **Apple Reminders** — автоматическое создание задач
- 📅 **Calendar** — события с датой и временем
- 🔒 **Lock Screen Widget** — быстрый доступ
- ⚡ **Action Button** — мгновенная запись (iPhone 15 Pro)
- 🎙️ **Siri Shortcuts** — голосовые команды

### UI/UX
- 🎨 **Dark Mode 2.0** — красивый тёмный интерфейс
- ✨ **Liquid Glass cards** — полупрозрачные карточки
- 🎭 **Type icons** — 📞 call / 👥 meeting / 🛒 purchase
- 🎯 **Priority badges** — 🔴 high / 🟡 medium / 🟢 low
- 🧠 **GPT-4 indicator** — видно когда используется AI

---

## 📋 Требования

- **iOS 17.0+**
- **iPhone** с Speech Recognition
- **Xcode 15.0+** для разработки
- **OpenAI API key** (опционально, для GPT-4)

---

## 🎯 Быстрый старт

### 1. Клонируйте репозиторий
```bash
git clone https://github.com/Vitalii-Karpenko80/mindy.git
cd mindy
```

### 2. Откройте в Xcode
```bash
open Mindy.xcodeproj
```

### 3. Настройте Bundle ID
- Выберите ваш Team
- Измените Bundle Identifier

### 4. Запустите
```
Cmd + R
```

### 5. (Опционально) Настройте GPT-4
1. Откройте **Настройки** ⚙️
2. Включите **"Использовать GPT-4"**
3. Добавьте API key с [platform.openai.com](https://platform.openai.com)

---

## 🧠 GPT-4 Интеграция

### Как это работает?

Mindy использует **гибридный подход**:

```swift
if useGPT4 && apiKeyConfigured {
    // Пробуем GPT-4 для максимальной точности
    result = await gpt4Service.parse(text)
} else {
    // Fallback на локальный парсер
    result = localParser.parse(text)
}
```

### Что умеет GPT-4?

| Возможность | Локальный | GPT-4 |
|------------|-----------|-------|
| Задачи | ✅ Ключевые слова | ✅ Контекст |
| Даты | ⚠️ Стандартные | ✅ Любые |
| Приоритет | ❌ | ✅ Автоматически |
| Тип | ❌ | ✅ Категоризация |
| Контекст | ⚠️ Частичный | ✅ Полный |

### Стоимость

- **Локальный парсер**: 💰 Бесплатно
- **GPT-4o**: ~$0.005 за запрос (~$5 за 1000 задач)

**100 задач в месяц**: ~$0.50

📖 Подробный гайд: [GPT4_GUIDE.md](GPT4_GUIDE.md)

---

## 💡 Примеры использования

### Простые задачи
```
"Завтра позвонить Сергею"
→ 📞 call | 🟡 medium | Завтра 09:00
```

### Покупки
```
"Купить молоко и хлеб сегодня"
→ 🛒 purchase | 🟢 low | Сегодня
```

### Встречи
```
"Через три дня встретиться с клиентом в районе полудня"
→ 👥 meeting | 🟡 medium | Через 3 дня, 12:00
```

### Сложные задачи
```
"К пятнице обязательно закончить отчёт, это критично"
→ ✅ task | 🔴 high | Пятница | "критично"
```

---

## 🏗 Архитектура

```
Mindy/
├── MindyApp.swift              # Entry point
│
├── Models/
│   └── Thought.swift           # Модель с priority, taskType
│
├── Services/
│   ├── SpeechRecognizer.swift  # Apple Speech API
│   ├── ThoughtParser.swift     # Локальный парсер
│   ├── GPT4ParsingService.swift # 🧠 GPT-4 интеграция
│   └── ThoughtManager.swift    # Гибридная логика
│
├── Views/
│   ├── ContentView.swift       # Главный экран
│   ├── SettingsView.swift      # ⚙️ Настройки + API key
│   └── DesignSystem.swift      # iOS 2026 компоненты
│
├── MindyWidget.swift           # Lock Screen Widget
└── QuickRecordIntent.swift     # App Intents для Shortcuts
```

**13 Swift файлов** | **~4000 строк кода**

---

## 🎨 Дизайн-система iOS 2026

### Liquid Glass Components

```swift
// Glass card с размытием
.liquidGlassCard(tintColor: .glassTint, cornerRadius: 24)

// Springy button с физикой
.springyButton(scale: 0.95)

// Soft depth shadow
.softDepthShadow(color: .accentPrimary, radius: 30)

// Pulsing effect
.pulsing(color: .accentPrimary)

// Animated gradient background
AnimatedGradientBackground()
```

### Color Palette

```swift
Cyber Blue   #66CCFF  // Основной акцент
Purple       #CC66FF  // Вторичный акцент
Pink         #FF80B3  // Третичный акцент
Deep Dark    #0D0D1F  // Фон
```

### Typography

- **Display** (48pt) — San Francisco Rounded Bold
- **Title** (32pt/24pt) — SF Rounded Semibold
- **Body** (17pt) — SF Rounded Regular
- **Caption** (13pt) — SF Rounded Medium

---

## 🎯 Использование

### Lock Screen Widget
1. Долгое нажатие на Lock Screen
2. **Customize** → Добавьте Mindy
3. Теперь можно записывать с экрана блокировки!

### Action Button (iPhone 15 Pro)
1. **Настройки → Action Button → Shortcut**
2. Выберите "Записать мысль"
3. Action Button открывает Mindy мгновенно!

### Siri
Скажите:
- "Hey Siri, open Mindy"
- "Записать мысль в Mindy"
- "Новая заметка в Mindy"

---

## 🧩 Технологии

- **SwiftUI** — Декларативный UI
- **Speech Framework** — Распознавание речи
- **OpenAI GPT-4o** — Умный парсинг
- **AVFoundation** — Аудио обработка
- **EventKit** — Reminders & Calendar
- **WidgetKit** — Lock Screen Widgets
- **App Intents** — Action Button & Siri
- **NaturalLanguage** — Локальный NLP

---

## 🎯 Roadmap

### v1.1
- [ ] Английский язык
- [ ] Apple Watch app
- [ ] iCloud синхронизация
- [ ] История редактирования

### v1.2
- [ ] macOS версия
- [ ] Теги и категории
- [ ] Поиск и фильтры
- [ ] Статистика

### v1.3
- [ ] Экспорт (Notion, Todoist, Things)
- [ ] Повторяющиеся задачи
- [ ] Геолокация для напоминаний
- [ ] Collaborative списки

---

## 🤝 Вклад

Contributions приветствуются!

1. Fork репозитория
2. Создайте branch (`git checkout -b feature/amazing`)
3. Commit (`git commit -m 'Add amazing feature'`)
4. Push (`git push origin feature/amazing`)
5. Откройте Pull Request

---

## 📄 Лицензия

MIT License — см. [LICENSE](LICENSE)

---

## 👨‍💻 Автор

**Виталий Карпенко**  
[GitHub](https://github.com/Vitalii-Karpenko80)

---

## 🙏 Благодарности

- **Apple** за Speech и EventKit
- **OpenAI** за GPT-4
- **iOS дизайн-сообщество** за тренды 2026

---

## 📸 Скриншоты

_Скриншоты будут добавлены после тестирования_

---

<div align="center">

**Сделано с 🧠 и ❤️**

**Mindy — Your AI Thought Companion**

*Think out loud. Mindy remembers.*

</div>
