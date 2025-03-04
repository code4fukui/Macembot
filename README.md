# Macembot

F503i and embot driver in Swift

## example

```
import Foundation

let emb = Macembot()

var n = 0
Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
  emb.led(idx: 1, n: n % 2 == 0, brightness: 255)
  n += 1
  print("\(n)")
}

RunLoop.main.run()
```

## API

- led(idx, n, brightness = 255) // idx:1-3, n:Bool
- buzzer(n) // 51=C?
- servo(idx, n) // idx:1-3, n:0-180
- getBrightness() -> Uint16 0-600
- setKeyDownListener(_ callback: (UInt32) -> Void)
- setKeyUpListener(_ callback: (UInt32) -> Void)

## demo

### LED

```
cd led
swiftc ../Macembot.swift main.swift
./main
```

### music

```
cd music
swiftc ../Macembot.swift main.swift
./main
```

### servo for EMBOT / EMBOTPLUS

```
cd servo_EMBOT
swiftc ../Macembot.swift main.swift
./main
```

### keys for F503i

```
cd keys_F503i
swiftc ../Macembot.swift main.swift
./main
```

### lightsensor for F503i

```
cd lightsensor_F503i
swiftc ../Macembot.swift main.swift
./main
```

### keyboard for F503i

```
cd keyboard_by_F503i
swiftc ../Macembot.swift main.swift
./main
```

## related

- [code4fukui/Webembot: Webembot is a driver API for embot, embot plus and F503i.](https://github.com/code4fukui/Webembot)
- [wakwak-koba/F503i: 小学館 小学8年生 2025年スペシャル4月号に付属の F503i を ESP32 で操るライブラリ](https://github.com/wakwak-koba/F503i)
