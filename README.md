<p align="center">
  <img src="https://img.shields.io/github/stars/muthuselvamlms/AgeRangeKit?style=for-the-badge" />
  <img src="https://img.shields.io/github/license/muthuselvamlms/AgeRangeKit?style=for-the-badge" />
  <img src="https://img.shields.io/badge/Platforms-iOS%20%7C%20macOS-blue?style=for-the-badge" />
  <img src="https://img.shields.io/badge/SPM-Supported-success?style=for-the-badge" />
  <img src="https://img.shields.io/cocoapods/v/AgeRangeKit?style=for-the-badge" />
  <img src="https://img.shields.io/github/actions/workflow/status/muthuselvamlms/AgeRangeKit/objective-c-xcode.yml?style=for-the-badge" />
</p>
## 🧠 **AgeRangeKit**

Drop-in mock for Apple’s **DeclaredAgeRange** API — works on simulator and older iOS versions.

A **hybrid compatibility wrapper** and **mock framework** for Apple’s `DeclaredAgeRange` API.  
It allows developers to build, test, and run apps that depend on Apple’s age-gating framework — even on **Simulators**, **older iOS versions**, and **VisionOS**, while automatically using the **real system API** when available.  

---

### ⚙️ **Why AgeRangeKit?**

Apple introduced `DeclaredAgeRange` to enforce age gating under US privacy law.  
However, it’s **not available on Simulators, older OS versions, or VisionOS**.  
That makes local testing and CI workflows painful.

✅ **AgeRangeKit fixes that.**
- Works in production and development.
- Fallback mock behavior for unsupported devices.
- Seamless switch to the Apple API when available.
- UI for DOB entry, sharing preferences, and parental control simulation.

---

### 🧩 **Installation**

#### 🟦 Swift Package Manager

In Xcode:
```
File → Add Packages → https://github.com/muthuselvam/AgeRangeKit.git
```

Or add this to your `Package.swift`:
```swift
.package(url: "https://github.com/muthuselvam/AgeRangeKit.git", from: "1.0.0")
```

#### ☕️ CocoaPods
Add to your `Podfile`:
```ruby
pod 'AgeRangeKit', :git => 'https://github.com/muthuselvam/AgeRangeKit.git'
```

Then run:
```bash
pod install
```

---

### 🧪 **Usage**

#### Import
```swift
import AgeRangeKit
```

#### Request an age range
```swift
do {
    let response = try await AgeRangeService.shared.requestAgeRange(ageGates: 13, 15, 18, in: window)
    switch response {
    case .sharing(let range):
        print("User is \(range.lowerBound ?? 0)+ years old")
    case .declinedSharing:
        print("User declined to share their age range.")
    }
} catch {
    print("Error requesting age range: \(error)")
}
```

#### Use MockAgeRangeProvider for unit testing
```swift
let mock = MockAgeRangeProvider(initialScenario: .sharingTeen)
let service = AgeRangeService(mock)
let response = try await service.requestAgeRange(ageGates: 13, in: window)
```

---

### 🧰 **SwiftUI Integration**

AgeRangeKit also supports the SwiftUI `@Environment` pattern:
```swift
@Environment(\.requestAgeRange) var requestAgeRange

Button("Check Age") {
    Task {
        let response = try await requestAgeRange(13, 15, 18, window)
        print(response)
    }
}
```

---

### 🏗️ **Architecture**

| Layer | Description |
|-------|--------------|
| `AgeRangeService` | Public API identical to Apple’s DeclaredAgeRange service. |
| `AppleAgeRangeProvider` | Delegates to Apple’s native DeclaredAgeRange on supported OS. |
| `MockAgeRangeProvider` | Developer testing mock — simulates every possible scenario instantly. |

---

### 📚 **Scenarios via MockAgeRangeProvider**

| Scenario | Result |
|-----------|---------|
| `.sharingChild` | Age < 13, with parental controls. |
| `.sharingTeen` | Age between 13–17. |
| `.sharingAdult` | Age ≥ 18. |
| `.declinedSharing` | User denies sharing. |
| `.errorNotAvailable` | Simulates unavailable system. |
| `.errorInvalidRequest` | Simulates malformed request. |
| `.errorUnknown` | Generic fallback error. |

---

### 🧾 **License**

MIT License © 2025 [Muthu L](https://github.com/muthuselvam)
