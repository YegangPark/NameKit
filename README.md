# NameKit

[![Swift](https://img.shields.io/badge/Swift-6.0-orange.svg)](https://swift.org)
[![Platform](https://img.shields.io/badge/Platform-iOS%2017+-blue.svg)](https://developer.apple.com/ios/)
[![License](https://img.shields.io/badge/License-MIT-black.svg)](LICENSE)

**NameKit** is a lightweight Swift library designed to intelligently extract a user's personal name from their iOS device name (e.g., "John" from "John's iPhone" or "예강" from "예강의 iPhone").

## 🚀 Features

- **Smart Extraction**: Uses a multi-layered approach to identify personal names.
- **Bilingual Support**: Specifically optimized for **English** and **Korean** device naming patterns.
- **Natural Language Processing**: Leverages Apple's `NaturalLanguage` framework (NLP) for robust name detection.
- **Safe Fallbacks**: Includes heuristic fallbacks for short names and edge cases.
- **Mockable**: Includes a protocol-based design for easy unit testing.
- **Swift 6 & Concurrency Ready**: Fully compatible with Swift 6 and strict concurrency checks.

## 🛠 How It Works

NameKit extracts names using the following priority:

1.  **Generic Filter**: Ignores generic device names like "iPhone", "iPad", or "MacBook".
2.  **Suffix Matching**: Handles common possessive patterns:
    - **English**: `'s iPhone`, `'s iPad`, `'s Phone`, etc.
    - **Korean**: `의 iPhone`, `의 아이폰`, `의 아이패드`, etc.
3.  **NLP Analysis**: Uses `NLTagger` with `.personalName` scheme to identify names in strings that don't follow standard suffix patterns.
4.  **Length-based Fallback**: If no clear name is found but the string is very short (≤ 4 characters), it's treated as a potential name.

## 📦 Installation

### Swift Package Manager

Add the following to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/NameKit.git", from: "1.0.0")
]
```

Or add it directly in Xcode via **File > Add Packages...**

## 📖 Usage

### Basic Usage

```swift
import NameKit

let extractor = NameExtractor()

// Extracts name from UIDevice.current.name (requires @MainActor)
if let name = await extractor.extract() {
    print("Hello, \(name)!") // e.g., "Hello, John!"
}
```

### Dependency Injection & Mocking

NameKit provides a `NameExtracting` protocol for easy testing.

```swift
import NameKit

class MyViewModel {
    let nameExtractor: NameExtracting
    
    init(nameExtractor: NameExtracting = NameExtractor()) {
        self.nameExtractor = nameExtractor
    }
    
    @MainActor
    func setupUser() {
        let name = nameExtractor.extract() ?? "Guest"
        // ...
    }
}

// In tests
let mock = MockNameExtractor(stubbedName: "Tester")
let viewModel = MyViewModel(nameExtractor: mock)
```

## 📋 Requirements

- iOS 17.0+
- Swift 6.0+
- Xcode 16.0+

## 📄 License

NameKit is available under the MIT license. See the [LICENSE](LICENSE) file for more info.
