# Macembot

> 日本語のREADMEはこちらです: [README.ja.md](README.ja.md)

F503i and embot driver in Swift

## Demo

### LED
```
cd led
swiftc ../Macembot.swift main.swift
./main
```

### Music
```
cd music
swiftc ../Macembot.swift main.swift
./main
```

### Servo for embot / embot+
```
cd servo_embot
swiftc ../Macembot.swift main.swift
./main
```

### Keys for F503i
```
cd keys_F503i
swiftc ../Macembot.swift main.swift
./main
```

### Light sensor for F503i
```
cd lightsensor_F503i
swiftc ../Macembot.swift main.swift
./main
```

### Keyboard for F503i
```
cd keyboard_by_F503i
swiftc ../Macembot.swift main.swift
./main
```

## Features

- Control LED, buzzer, and servo motors for embot, embot+, and F503i devices
- Access light sensor and keyboard input on F503i
- Swift-based driver API

## Requirements

- Swift 5.0 or later
- Xcode

## Usage

1. Clone the repository
2. Navigate to the desired demo directory
3. Compile the Swift code with `swiftc ../Macembot.swift main.swift`
4. Run the compiled binary with `./main`

## License

MIT License — see [LICENSE](LICENSE).