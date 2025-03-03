import Foundation
import CoreBluetooth
import CoreGraphics

func uuid(s: String) -> String {
  return "f7fc" + s + "-7a0b-4b89-a675-a79137223e2c"
}
func getCharacter(in text: String, at index: Int) -> Character? {
  guard index >= 0 && index < text.count else { return nil }
  return text[text.index(text.startIndex, offsetBy: index)]
}
func charToUnicode(_ char: Character?, defvalue: UInt32) -> UInt32 {
  guard let n = char?.unicodeScalars.first?.value else { return defvalue }
  return n
}
func sendKeyDown(_ key: CGKeyCode, flags: CGEventFlags = []) {
  if key == 0 { return }
  let source = CGEventSource(stateID: .hidSystemState)
  let keyDown = CGEvent(keyboardEventSource: source, virtualKey: key, keyDown: true)
  keyDown?.flags = flags // 特殊キー（Shift, Command, etc）
  keyDown?.post(tap: .cghidEventTap)
}
func sendKeyUp(_ key: CGKeyCode) {
  if key == 0 { return }
  let source = CGEventSource(stateID: .hidSystemState)
  let keyUp = CGEvent(keyboardEventSource: source, virtualKey: key, keyDown: false)
  keyUp?.post(tap: .cghidEventTap)
}
func sendKeyDownSharp() { // NG
  let source = CGEventSource(stateID: .hidSystemState)
  let keyDown = CGEvent(keyboardEventSource: source, virtualKey: 71, keyDown: true) // #
  keyDown?.flags = [.maskShift]
  keyDown?.post(tap: .cghidEventTap)
}
func sendKeyUpSharp() {
  let source = CGEventSource(stateID: .hidSystemState)
  let keyUp = CGEvent(keyboardEventSource: source, virtualKey: 71, keyDown: false)
  keyUp?.flags = [.maskShift]
  keyUp?.post(tap: .cghidEventTap)
}
func mapKey(_ key: UInt32) -> CGKeyCode {
  if key >= 48 && key <= 55 {
    return UInt16(key - 48 + 82)
  } else if key >= 56 && key <= 57 {
    return UInt16(key - 48 + 83)
  } else if key == 35 {
    return 67
  } else if key == 42 {
    return 71
  }
  return 0
}
func sendTenkeyDown(_ key: UInt32) {
  if key == 42 { // sharp
    //print("sharp")
    //sendKeyDownSharp()
    sendKeyDown(51) // backspace
  } else if key == 35 { // asterisk
    sendKeyDown(36) // enter
  } else {
    sendKeyDown(mapKey(key))
  }
}
func sendTenkeyUp(_ key: UInt32) {
  if key == 42 {
    //sendKeyUpSharp()
    sendKeyUp(51) // backspace
  } else if key == 35 { // asterisk
    sendKeyUp(36) // enter
  } else {
    sendKeyUp(mapKey(key))
  }
}

class BLEWriter: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
  let targetDeviceName = "F503i_" // ここにデバイス名を設定
  //let serviceUUID = CBUUID(string: "f7fce510-7a0b-4b89-a675-a79137223e2c") // サービスUUID
  let serviceUUID = CBUUID(string: uuid(s: "e510")) // サービスUUID
  let characteristicUUID = CBUUID(string: uuid(s: "e517")) // キャラクタリスティックUUID LED green
  let chUUIDKey = CBUUID(string: uuid(s: "e531")) // キャラクタリスティックUUID key
  let chUUIDLightSensor = CBUUID(string: uuid(s: "e532")) // キャラクタリスティックUUID light sensor

  var centralManager: CBCentralManager!
  var targetPeripheral: CBPeripheral?
  var targetCharacteristic: CBCharacteristic?
  var lightSensorCharacteristic: CBCharacteristic?
  var keyCharacteristic: CBCharacteristic?

  var keystate: UInt16 = 0b11111111111
  var keys = "0123456789*#"

  override init() {
    super.init()
    centralManager = CBCentralManager(delegate: self, queue: nil)
  }

  // ✅ Bluetoothの状態を確認
  func centralManagerDidUpdateState(_ central: CBCentralManager) {
    if central.state == .poweredOn {
      print("🔵 Bluetooth が有効、スキャンを開始")
      //centralManager.scanForPeripherals(withServices: [serviceUUID], options: nil) // アドバタイズしていないのでNG
      centralManager.scanForPeripherals(withServices: [], options: nil)
    } else {
      print("❌ Bluetooth を使用できません")
    }
  }

  // ✅ デバイスを発見
  func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String: Any], rssi RSSI: NSNumber) {
    print("📡 発見: \(peripheral.name ?? "Unknown")")
    guard let name = peripheral.name else {
      return
    }    
    if name.hasPrefix(targetDeviceName) {
      targetPeripheral = peripheral
      targetPeripheral?.delegate = self
      centralManager.stopScan()
      centralManager.connect(peripheral, options: nil)
    }
  }

  // ✅ 接続成功
  func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
    print("✅ 接続成功: \(peripheral.name ?? "Unknown")")
    peripheral.discoverServices([serviceUUID])
  }

  // ✅ サービスを発見
  func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
    guard let services = peripheral.services else { return }
    for service in services {
      if service.uuid == serviceUUID {
        print("🛠 サービス発見: \(service.uuid)")
        //peripheral.discoverCharacteristics([characteristicUUID, chUUIDLightSensor], for: service)
        peripheral.discoverCharacteristics([], for: service)
      }
    }
  }

  // ✅ キャラクタリスティックを発見
  func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
    guard let characteristics = service.characteristics else { return }
    for characteristic in characteristics {
      if characteristic.uuid == characteristicUUID {
        print("✍️ キャラクタリスティック発見: \(characteristic.uuid)")
        targetCharacteristic = characteristic
      } else if characteristic.uuid == chUUIDLightSensor {
        print("✍️ キャラクタリスティック発見: \(characteristic.uuid)")
        lightSensorCharacteristic = characteristic
      } else if characteristic.uuid == chUUIDKey {
        print("📥 Notify キャラクタリスティック発見: \(characteristic.uuid)")
        keyCharacteristic = characteristic
        peripheral.setNotifyValue(true, for: characteristic) // 🔔 Notify を有効化
        // peripheral.setNotifyValue(false, for: characteristic) // 解除
      }
    }
  }

  // ✅ キャラクタリスティックに値を書き込む
  func led(n: Bool) {
    guard let peripheral = targetPeripheral, let characteristic = targetCharacteristic else { return }
    let writeValue = Data([n ? 255 : 0]) // 書き込む値（例: 1バイトのデータ）
    print("🚀 データを書き込み中: \(writeValue as NSData)")
    //peripheral.writeValue(writeValue, for: characteristic, type: .withResponse)
    peripheral.writeValue(writeValue, for: characteristic, type: .withoutResponse)
  }

  // ✅ 書き込み完了通知
  func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
    if let error = error {
      print("❌ 書き込みエラー: \(error.localizedDescription)")
    } else {
      print("✅ 書き込み成功")
    }
    centralManager.cancelPeripheralConnection(peripheral) // 書き込み後に切断
  }
  func getBrightness() {
    guard let peripheral = targetPeripheral, let characteristic = lightSensorCharacteristic else { return }
    peripheral.readValue(for: characteristic)
  }
  // ✅ 読み取りが完了したとき、Notify を受信したとき
  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    if let error = error {
      print("❌ データ読み取りエラー: \(error.localizedDescription)")
      return
    }
    guard let value = characteristic.value else {
      print("⚠️ データなし")
      return
    }
    
    // 🔍 2 バイトのデータをリトルエンディアンで変換
    let number = value.withUnsafeBytes { $0.load(as: UInt16.self).littleEndian }
    if characteristic == keyCharacteristic {
      print("🔢 keystate: \(String(number, radix: 2))")
      let down = keystate & ~number // 1 -> 0
      let up = ~keystate & number // 0 -> 1
      for i in 0...11 {
        let c = charToUnicode(getCharacter(in: keys, at: i), defvalue: 0)
        if (down & (1 << i)) != 0 {
          //print("key down: \(c)")
          sendTenkeyDown(c)
        } else if (up & (1 << i)) != 0 {
          //print("key up: \(c)")
          sendTenkeyUp(c)
        }
      }
      keystate = number
    } else if characteristic == lightSensorCharacteristic {
      print("🔢 brightness: \(number)")
    }
  }
}

let emb = BLEWriter()

var counter = 0
Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
  emb.getBrightness()
  //emb.led(n: counter % 2 == 1)
  counter += 1
  // timer.invalidate()
}

RunLoop.main.run()
