## 🧠 **DeclaredAgeRangeKit**

A **hybrid compatibility wrapper** and **mock framework** for Apple’s `DeclaredAgeRange` API.  
It allows developers to build, test, and run apps that depend on Apple’s age-gating framework — even on **Simulators**, **older iOS versions**, and **VisionOS**, while automatically using the **real system API** when available.  

---

### ⚙️ **Why DeclaredAgeRangeKit?**

Apple introduced `DeclaredAgeRange` to enforce age gating under US privacy law.  
However, it’s **not available on Simulators, older OS versions, or VisionOS**.  
That makes local testing and CI workflows painful.

✅ **DeclaredAgeRangeKit fixes that.**
- Works in production and development.
- Fallback mock behavior for unsupported devices.
- Seamless switch to the Apple API when available.
- UI for DOB entry, sharing preferences, and parental control simulation.

---

### 🏗️ **Architecture**

| Layer | Description |
|-------|--------------|
| `AgeRangeService` | Public API identical to Apple’s DeclaredAgeRange service. |
| `AppleAgeRangeProvider` | Delegates to Apple’s native DeclaredAgeRange on supported OS. |
| `MockAgeRangeProvider` | Customizable fallback with settings-driven DOB & sharing preference. |
| `SimpleMockAgeRangeProvider` | Developer testing mock — simulates every possible scenario instantly. |

---

### 🧩 **Installation**

#### 🟦 Swift Package Manager

In Xcode:
```
File → Add Packages → https://github.com/muthuselvam/DeclaredAgeRangeKit.git
```

Or add this to your `Package.swift`:
```swift
.package(url: "https://github.com/muthuselvam/DeclaredAgeRangeKit.git", from: "1.0.0")
```

#### ☕️ CocoaPods
Add to your `Podfile`:
```ruby
pod 'DeclaredAgeRangeKit', :git => 'https://github.com/muthuselvam/DeclaredAgeRangeKit.git'
```

Then run:
```bash
pod install
```

---

### 🧪 **Usage**

#### Import
```swift
import DeclaredAgeRangeKit
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

#### Use SimpleMockAgeRangeProvider for unit testing
```swift
let mock = SimpleMockAgeRangeProvider(initialScenario: .sharingTeen)
let service = AgeRangeService(mock)
let response = try await service.requestAgeRange(ageGates: 13, in: window)
```

---

### 🧰 **SwiftUI Integration**

DeclaredAgeRangeKit also supports the SwiftUI `@Environment` pattern:
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

### ⚙️ **Mock Settings**

On **Simulator builds**, DeclaredAgeRangeKit automatically adds two configurable items in the iOS **Settings** app:
- **Date of Birth**
- **Sharing Preference** (`Always Share`, `Ask First`, `Never`)

Real devices with iOS ≥ 26 automatically use Apple’s native DeclaredAgeRange API.

---

### 📚 **Scenarios via SimpleMockAgeRangeProvider**

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
