# Инструкция по настройке проекта в Xcode

Поскольку файлы `.xcodeproj` генерируются автоматически, следуйте этим инструкциям для создания проекта:

## Шаг 1: Создание iOS App проекта

1. Откройте Xcode
2. Выберите **File → New → Project**
3. Выберите **iOS → App**
4. Заполните данные:
   - **Product Name:** HandoverKZ
   - **Team:** Выберите вашу команду разработки
   - **Organization Identifier:** com.yourcompany (или свой)
   - **Interface:** SwiftUI
   - **Language:** Swift
   - **Minimum Deployments:** iOS 17.0
5. Сохраните проект в папку `/workspace/HandoverKZ`

## Шаг 2: Добавление FieldDocsCore Package

1. В Xcode выберите проект HandoverKZ в навигаторе
2. Выберите таргет HandoverKZ
3. Перейдите на вкладку **General**
4. В разделе **Frameworks, Libraries, and Embedded Content** нажмите **+**
5. Выберите **Add Package Dependency**
6. В поле поиска укажите путь: `/workspace/FieldDocsCore`
7. Нажмите **Add Package**
8. Выберите **FieldDocsCore** и нажмите **Add Package**

## Шаг 3: Замена сгенерированных файлов

1. Удалите автоматически созданные файлы:
   - `HandoverKZApp.swift` (если создан Xcode)
   - `ContentView.swift` (если создан Xcode)

2. Убедитесь, что все файлы из репозитория подключены к проекту:
   - `HandoverKZApp.swift`
   - `ContentView.swift`
   - `DesignSystem/DesignSystem.swift`
   - `DesignSystem/Components.swift`
   - `Views/` (все файлы)
   - `Resources/` (все файлы локализации)
   - `Info.plist`

3. Если файлы не видны в проекте, добавьте их через **Add Files to "HandoverKZ"**

## Шаг 4: Настройка Info.plist

1. Выберите проект HandoverKZ в навигаторе
2. Выберите таргет HandoverKZ
3. Перейдите на вкладку **Info**
4. Убедитесь, что используется `Info.plist` из репозитория
5. Проверьте наличие следующих ключей:
   - `NSCameraUsageDescription`
   - `NSPhotoLibraryUsageDescription`
   - `CFBundleLocalizations` (ru, kk)

## Шаг 5: Настройка локализации

1. В проекте выберите **Resources** папку
2. Добавьте файлы локализации:
   - `ru.lproj/Localizable.strings`
   - `kk.lproj/Localizable.strings`

## Шаг 6: Настройка подписи кода

1. Выберите проект HandoverKZ
2. Выберите таргет HandoverKZ
3. Перейдите на вкладку **Signing & Capabilities**
4. Включите **Automatically manage signing**
5. Выберите вашу команду разработки

## Шаг 7: Сборка проекта

1. Выберите схему **HandoverKZ**
2. Выберите целевое устройство или симулятор (iPhone/iPad с iOS 17+)
3. Нажмите ⌘B для сборки или ⌘R для запуска

## Возможные проблемы

### Ошибка: "Cannot find 'FieldDocsCore' in scope"

**Решение:** Убедитесь, что FieldDocsCore Package добавлен в зависимости проекта.

### Ошибка: "Missing required entitlements"

**Решение:** Проверьте настройки подписи кода и убедитесь, что выбрана правильная команда разработки.

### Ошибка: "Camera permission"

**Решение:** Убедитесь, что `Info.plist` содержит `NSCameraUsageDescription` и `NSPhotoLibraryUsageDescription`.

## Тестирование на симуляторе

Для тестирования на симуляторе:
1. Выберите симулятор (например, iPhone 15 Pro)
2. Нажмите ⌘R
3. Приложение запустится на симуляторе

**Примечание:** На симуляторе камера может быть недоступна. Используйте выбор из галереи.

## Тестирование на физическом устройстве

1. Подключите iPhone/iPad к Mac
2. Выберите устройство в списке целей
3. Убедитесь, что устройство доверяет вашему Mac
4. Нажмите ⌘R
5. На устройстве может потребоваться подтверждение доверия сертификату разработчика (**Settings → General → Device Management**)

---

После выполнения всех шагов проект должен успешно собираться и запускаться.
