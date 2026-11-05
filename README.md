# UniLib

Основа библиотеки для Minecraft по схеме UniGUI: независимый Java core, отдельные сборки legacy и общие исходники современных версий под Stonecutter.

| Minecraft | Загрузчики / окружение                           | Java модуля            | Gradle                                   |
|-----------|--------------------------------------------------|------------------------|------------------------------------------|
| core      | Без Minecraft и сторонних runtime-зависимостей   | 17 (компилятор JDK 17) | 8.12.1 либо Gradle родительского проекта |
| 1.7.10    | Forge / GTNH, RetroFuturaGradle через GTNHGradle | 21                     | 9.7.1, запуск на JDK 25                  |
| 1.12.2    | Cleanroom 0.7.14-alpha / CleanroomGradle         | 25                     | 9.8.1, запуск на JDK 25                  |
| 1.20.1    | Fabric, Forge                                    | 17                     | 8.12.1, запуск на JDK 21                 |
| 1.21.1    | Fabric, Forge, NeoForge                          | 21                     | 8.12.1, запуск на JDK 21                 |

Сейчас профили 1.20–1.21 представлены версиями **1.20.1 и 1.21.1**, как в UniGUI. Поддержка остальных патч-версий требует отдельных профилей и проверки API.

## Структура

```text
core/                 Общий API и логика без импортов Minecraft
common/               Общая интеграция современных версий Minecraft
fabric/               Fabric entry point и metadata
forge/                Forge entry point и metadata
neoforge/             NeoForge entry point и metadata
versions/1.20.1/       Параметры профиля Stonecutter
versions/1.21.1/       Параметры профиля Stonecutter
1.7.10-gtnh/          Самостоятельный проект GTNH со своим wrapper
1.12.2-cleanroom/     Самостоятельный проект Cleanroom со своим wrapper
```

`core` подключается через `project(':core')` во всех сборках и автоматически включается в итоговые mod JAR. Отдельно устанавливать core в `mods` не нужно. В IDEA все три Gradle-сборки связаны через `.idea/gradle.xml`, как в UniGUI: современная, `1.7.10-gtnh` и `1.12.2-cleanroom` отображаются в одном окне Gradle. Legacy-проекты используют собственные wrapper и плагины.

После изменения настроек IDEA выполните **Reload All Gradle Projects**; если новые связанные сборки не появились, переоткройте проект. JVM каждой сборки берётся из её локального `.gradle/config.properties` (`#GRADLE_LOCAL_JAVA_HOME`): JDK 21 в корне и JDK 25 в legacy-проектах. Эти локальные файлы не хранятся в Git; на другой машине задайте JDK через настройки Gradle JVM в IDEA. Core использует toolchain Java 17 независимо от JVM сборки.

В этой основе есть идентификатор библиотеки `dev.sixik.unilib.UniLib`, точки входа загрузчиков и конфигурация сборки. Предметные API библиотеки пока не добавлены. Minecraft-зависимую логику следует размещать в соответствующих backend-модулях.

## Сборка

Команды ниже для PowerShell, выполняются из корня UniLib. Установите JDK 17, JDK 21 и JDK 25. Core всегда компилируется JDK 17 с `--release 17`, независимо от JVM, на которой запущен Gradle. Пути `JAVA_HOME` замените на свои.

Только core, без конфигурации Minecraft и загрузки моддинговых плагинов:

```powershell
$env:JAVA_HOME = 'C:\Program Files\Java\jdk-17'
.\gradlew.bat -p core build
```

Все современные платформы:

```powershell
$env:JAVA_HOME = 'C:\Program Files\Java\jdk-21'
.\gradlew.bat buildModern
```

Корневая сборка конфигурирует также Minecraft 1.21.1, поэтому Gradle в ней нужно запускать на JDK 21 даже для задачи `:core:build`. Чтобы собрать только core на JDK 17, используйте `-p core`: отдельный проект не конфигурирует Minecraft.

Одна конкретная платформа:

```powershell
.\gradlew.bat :1.20.1:forge:build
.\gradlew.bat :1.21.1:neoforge:build
.\gradlew.bat :1.20.1:fabric:runClient
```

Legacy-проекты: JDK 25 требуется самим плагинам сборки, включая GTNH с целевым байткодом Java 21.

```powershell
$env:JAVA_HOME = 'C:\Program Files\Java\jdk-25.0.2'
.\1.7.10-gtnh\gradlew.bat -p 1.7.10-gtnh build
.\1.12.2-cleanroom\gradlew.bat -p 1.12.2-cleanroom build
```

Для запуска игры используйте `runClient` у Cleanroom и `runClient21` у GTNH. На Linux/macOS вместо `gradlew.bat` используйте `./gradlew` соответствующего проекта и задайте `JAVA_HOME` средствами своей оболочки.

Итоговые файлы:

- `core/build/libs/unilib-core-<version>.jar` — самостоятельная библиотека core.
- `build/stonecutter/<mc>/<loader>/libs/unilib-<loader>-<mc>-<version>.jar` — современные моды.
- `1.7.10-gtnh/build/libs/unilib-gtnh-1.7.10-<version>.jar`.
- `1.12.2-cleanroom/build/libs/unilib-cleanroom-1.12.2-<version>.jar`.

Для установки используйте JAR без `dev`, `dev-shadow`, `mcp` или `sources` в имени.

После сборки всех платформ можно проверить наличие core и entry point, версии байткода, подстановку metadata и версию GTNH-аннотации:

```powershell
.\tools\verify-artifacts.ps1
```

## Версии и публикация

Общая версия, Maven group и имя артефактов задаются в корневом `gradle.properties`. Legacy-проекты читают его напрямую; GTNH не требует Git-тегов. Core и современные/Cleanroom-модули используют `maven-publish`; например, `:core:publishToMavenLocal`. Удалённый Maven-репозиторий не настроен.

## Stonecutter

Активный профиль задаётся в `stonecutter.gradle` (`1.20.1` по умолчанию). Общие исходники лежат в `common`, `fabric`, `forge`, `neoforge`; build-каталоги разделены по версии и загрузчику. Для различий API используйте директивы Stonecutter:

```java
//? if >=1.21 {
// код для профиля 1.21.1
//?} else {
/* код для профиля 1.20.1 */
//?}
```

Для нового профиля добавьте его в список `versions` и матрицу модулей `settings.gradle`, создайте `versions/<mc>/gradle.properties`, обновите `buildModern` и проверку артефактов. Legacy-модули не обрабатываются Stonecutter.
