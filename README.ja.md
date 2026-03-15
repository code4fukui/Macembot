# Macembot

F503iとembotのSwiftドライバです。

## デモ

以下のデモがあります。

### LED
LEDの点灯/消灯のデモ
```
cd led
swiftc ../Macembot.swift main.swift
./main
```

### 音楽
音楽の再生デモ
```
cd music
swiftc ../Macembot.swift main.swift
./main
```

### サーボ (embot / embot+)
サーボの制御デモ
```
cd servo_embot
swiftc ../Macembot.swift main.swift
./main
```

### キー (F503i)
キーの検知デモ
```
cd keys_F503i
swiftc ../Macembot.swift main.swift
./main
```

### 光センサー (F503i)
光センサーの値取得デモ
```
cd lightsensor_F503i
swiftc ../Macembot.swift main.swift
./main
```

### キーボード (F503i)
キーボードのシミュレーションデモ
```
cd keyboard_by_F503i
swiftc ../Macembot.swift main.swift
./main
```

## 機能

- LED制御
- ブザー制御
- サーボ制御
- 光センサー値取得
- キー入力検知
- キーボードシミュレーション

## 必要環境

- macOS
- Swift

## 使い方

以下のように使用できます:

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

## 関連

- [code4fukui/Webembot: Webembotは、embotとembot plus、F503iのドライバAPIです。](https://github.com/code4fukui/Webembot)
- [wakwak-koba/F503i: 小学館 小学8年生 2025年スペシャル4月号に付属の F503i を ESP32 で操るライブラリ](https://github.com/wakwak-koba/F503i)

## ライセンス

[MIT License](LICENSE)