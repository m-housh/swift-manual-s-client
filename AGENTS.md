# Manual S HVAC Calculation Project - Agent Guidelines

## Project Overview
Swift server-side web application for HVAC Manual-S equipment selection calculations (2014 edition).
- **Stack:** Swift 6.2, Vapor 4, SQLite (Fluent), Elementary HTML DSL, HTMX
- **Architecture:** Modular (Models/Client/Database/Router/ViewController)

## Build, Test & Run Commands

Use `just` command runner or `swift` directly:

| Task | Command |
|------|---------|
| Run server (port 8081) | `just run` or `swift run server serve --port 8081` |
| Run all tests | `just test` or `swift test --enable-code-coverage` |
| Run single test | `swift test --filter ManualSClientTests` |
| Run single test function | `swift test --filter ManualSClientTests/requiredKW` |
| Code coverage | `just code-coverage` |
| Clean build | `just clean` |
| Docker test | `just test-docker` |

**Single test filtering:** Use pattern `TestSuiteName/TestFunctionName`
Example: `swift test --filter ManualSClientTests/coolingDeratings`

## Code Style Guidelines

### Imports
- Group: Apple frameworks → Third-party → Internal modules → @_exported
- Alphabetically within groups
- Use `@_exported import` for re-exported types (e.g., `SharedModels.Project`)

### Formatting
- 2-space indentation (no tabs)
- No trailing whitespace
- Max line length: 100 characters preferred
- No formal formatter configured (follow existing patterns)

### Naming Conventions
- Types: PascalCase (e.g., `CoolingInterpolation`, `ManualSClient`)
- Variables/functions: camelCase, descriptive (e.g., `coolingDerating`, `capacityAtDesign`)
- Protocols: PascalCase, often end in -able/-ible (e.g., `Validatable`)
- Tagged types: Use `Tag` namespace (e.g., `ManualSClient.Tag.Elevation`)

### Types & Architecture
- Mark all public types as `Sendable` for concurrency safety
- Use `Tagged<Tag, RawValue>` for type-safe identifiers
- Use `@DependencyClient` macro for dependency injection
- Use `@CasePathable` and `@dynamicMemberLookup` for enum access
- Model structs should be `Codable, Equatable, Identifiable, Sendable`
- Define request/response types as nested types within main type

### Error Handling
- Use `throws` for async functions that can fail
- Prefer specific error types over generic `Error`
- Validation errors handled via `Validations` library

### Testing (Swift Testing Framework)
- Use `@Suite` for test classes, `@Test` for test functions
- Use parameterized tests with `@Test(arguments: [])`
- Assert with `#expect()` and `#expect(throws:)`
- Use `withDependencies` for mocking:
  ```swift
  try await withDependencies {
    $0.manualS = .liveValue
  } operation: {
    @Dependency(\.manualS) var manualS
    let sut = try await manualS.function()
    #expect(sut == expected)
  }
  ```

### Key Patterns
- **Dependency Injection:** Use `swift-dependencies` with `@DependencyClient` macro
- **Routing:** Type-safe routing via `swift-url-routing`
- **HTML:** Server-side rendering with Elementary DSL + HTMX interactivity
- **Database:** Fluent ORM with SQLite
- **Validation:** Custom validations via `Validations` library

### Module Structure
- `ManualSModels`: Domain models, validation, tagged types
- `ManualSClient`: Business logic, calculations, dependency definitions
- `ManualSDatabase`: Database layer, migrations, queries
- `ManualSRouter`: URL routing definitions
- `ManualSViewController`: HTML views, forms, HTMX handlers

### Comments & TODOs
- Use `// FIX:` for known issues requiring attention
- Use `// TODO:` for planned improvements
- Wrap debug/mock data in `#if DEBUG` blocks

## CI/CD
- GitHub Actions runs on PRs and main branch pushes
- Linux-only testing via Docker (swift:6.2-noble)
- Uses Docker buildx with GitHub Actions cache
