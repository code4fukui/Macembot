# Macembot

Swiftで実装されたF503iおよびembot用ドライバ

## デモ

### LED
```
cd led
swiftc ../Macembot.swift main.swift
./main
```

### 音楽
```
cd music
swiftc ../Macembot.swift main.swift
./main
```

### embot / embot+用サーボ
```
cd servo_embot
swiftc ../Macembot.swift main.swift
./main
```

### F503i用キー
```
cd keys_F503i
swiftc ../Macembot.swift main.swift
./main
```

### F503i用光センサー
```
cd lightsensor_F503i
swiftc ../Macembot.swift main.swift
./main
```

### F503i用キーボード
```
cd keyboard_by_F503i
swiftc ../Macembot.swift main.swift
./main
```

## 機能

- embot、embot+、およびF503iデバイスのLED、ブザー、サーボモーターの制御
- F503iの光センサーおよびキーボード入力へのアクセス
- SwiftベースのドライバAPI

## 必要条件

- Swift 5.0以降
- Xcode

## 使い方

1. リポジトリをクローンする
2. 目的のデモディレクトリに移動する
3. `swiftc ../Macembot.swift main.swift` でSwiftコードをコンパイルする
4. `./main` でコンパイル済みバイナリを実行する

## ライセンス

MIT License — [LICENSE](LICENSE) を参照。
