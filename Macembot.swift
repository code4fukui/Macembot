import Foundation
import CoreBluetooth

func uuid(_ s: String) -> String {
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

class Macembot: NSObject, CBCentralManagerDelegate, CBPeripheralDelegate {
  let prefixF503i = "F503i_"
  let prefixEMBOT = "EMBOT_"
  let prefixEMBOTPLUS = "EMBOTPLUS_"
  //let serviceUUID = CBUUID(string: "f7fce510-7a0b-4b89-a675-a79137223e2c") // サービスUUID
  let serviceUUID = CBUUID(string: uuid("e510")) // サービスUUID
  var f503i: Bool = false
  // EMBOT
  let chUUIDLED1_EMBOT = CBUUID(string: uuid("e515")) // キャラクタリスティックUUID LED1
  let chUUIDLED2_EMBOT = CBUUID(string: uuid("e516")) // キャラクタリスティックUUID LED2
  let chUUIDServo1 = CBUUID(string: uuid("e511"))
  let chUUIDServo2 = CBUUID(string: uuid("e512"))
  let chUUIDServo3 = CBUUID(string: uuid("e513"))
  // F503i
  let chUUIDLED1 = CBUUID(string: uuid("e517")) // キャラクタリスティックUUID LED green
  let chUUIDLED2 = CBUUID(string: uuid("e518")) // キャラクタリスティックUUID LED yellow
  let chUUIDLED3 = CBUUID(string: uuid("e51b")) // キャラクタリスティックUUID LED red
  let chUUIDKey = CBUUID(string: uuid("e531")) // キャラクタリスティックUUID key
  let chUUIDLightSensor = CBUUID(string: uuid("e532")) // キャラクタリスティックUUID light sensor
  // common
  let chUUIDBuzzer = CBUUID(string: uuid("e521")) // buzzer

  var centralManager: CBCentralManager!
  var targetPeripheral: CBPeripheral?
  var led1Characteristic: CBCharacteristic?
  var led2Characteristic: CBCharacteristic?
  var led3Characteristic: CBCharacteristic?
  var lightSensorCharacteristic: CBCharacteristic?
  var keyCharacteristic: CBCharacteristic?
  var buzzerCharacteristic: CBCharacteristic?
  var servo1Characteristic: CBCharacteristic?
  var servo2Characteristic: CBCharacteristic?
  var servo3Characteristic: CBCharacteristic?

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
    if name.hasPrefix(prefixF503i) || name.hasPrefix(prefixEMBOT) || name.hasPrefix(prefixEMBOTPLUS) {
      targetPeripheral = peripheral
      targetPeripheral?.delegate = self
      centralManager.stopScan()
      centralManager.connect(peripheral, options: nil)
      f503i = name.hasPrefix(prefixF503i)
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
      if f503i {
        if characteristic.uuid == chUUIDLED1 {
          print("✍️ LED1 キャラクタリスティック発見: \(characteristic.uuid)")
          led1Characteristic = characteristic
        } else if characteristic.uuid == chUUIDLED2 {
          print("✍️ LED2 キャラクタリスティック発見: \(characteristic.uuid)")
          led2Characteristic = characteristic
        } else if characteristic.uuid == chUUIDLED3 {
          print("✍️ LED3 キャラクタリスティック発見: \(characteristic.uuid)")
          led3Characteristic = characteristic
        } else if characteristic.uuid == chUUIDLightSensor {
          print("✍️ light sensor キャラクタリスティック発見: \(characteristic.uuid)")
          lightSensorCharacteristic = characteristic
        } else if characteristic.uuid == chUUIDKey {
          print("📥 keyboard キャラクタリスティック発見: \(characteristic.uuid)")
          keyCharacteristic = characteristic
          peripheral.setNotifyValue(true, for: characteristic) // 🔔 Notify を有効化
          // peripheral.setNotifyValue(false, for: characteristic) // Notify を解除
        }
      } else {
        if characteristic.uuid == chUUIDLED1_EMBOT {
          print("✍️ LED1 キャラクタリスティック発見: \(characteristic.uuid)")
          led1Characteristic = characteristic
        } else if characteristic.uuid == chUUIDLED2_EMBOT {
          print("✍️ LED2 キャラクタリスティック発見: \(characteristic.uuid)")
          led2Characteristic = characteristic
        } else if characteristic.uuid == chUUIDServo1 {
          print("✍️ Servo1 キャラクタリスティック発見: \(characteristic.uuid)")
          servo1Characteristic = characteristic
        } else if characteristic.uuid == chUUIDServo2 {
          print("✍️ Servo2 キャラクタリスティック発見: \(characteristic.uuid)")
          servo2Characteristic = characteristic
        } else if characteristic.uuid == chUUIDServo3 {
          print("✍️ Servo3 キャラクタリスティック発見: \(characteristic.uuid)")
          servo3Characteristic = characteristic
        }
      }
      // common
      if characteristic.uuid == chUUIDBuzzer {
        print("✍️ buzzer キャラクタリスティック発見: \(characteristic.uuid)")
        buzzerCharacteristic = characteristic
      }
    }
  }
  func led(idx: Int, n: Bool, brightness: UInt8 = 255) {
    guard let peripheral = targetPeripheral else { return }
    let writeValue = Data([f503i ? (n ? brightness : 0) : (n ? 1 : 2)])
    if idx == 1 {
      guard let ch = led1Characteristic else { return }
      peripheral.writeValue(writeValue, for: ch, type: .withoutResponse)
    } else if idx == 2 {
      guard let ch = led2Characteristic else { return }
      peripheral.writeValue(writeValue, for: ch, type: .withoutResponse)
    } else if idx == 3 {
      guard let ch = led3Characteristic else { return }
      peripheral.writeValue(writeValue, for: ch, type: .withoutResponse)
    }
  }
  func servo(idx: Int, n: Int) {
    guard let peripheral = targetPeripheral else { return }
    let writeValue = Data([UInt8(n)])
    if idx == 1 {
      guard let ch = servo1Characteristic else { return }
      peripheral.writeValue(writeValue, for: ch, type: .withoutResponse)
    } else if idx == 2 {
      guard let ch = servo2Characteristic else { return }
      peripheral.writeValue(writeValue, for: ch, type: .withoutResponse)
    } else if idx == 3 {
      guard let ch = servo3Characteristic else { return }
      peripheral.writeValue(writeValue, for: ch, type: .withoutResponse)
    }
  }
  func buzzer(n: Int) {
    guard let peripheral = targetPeripheral, let characteristic = buzzerCharacteristic else { return }
    let writeValue = Data([UInt8(n)]) // 書き込む値（例: 1バイトのデータ）
    peripheral.writeValue(writeValue, for: characteristic, type: .withoutResponse)
  }
  /*
  // ✅ 書き込み完了通知
  func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
    if let error = error {
      print("❌ 書き込みエラー: \(error.localizedDescription)")
    } else {
      print("✅ 書き込み成功")
    }
    // centralManager.cancelPeripheralConnection(peripheral) // 書き込み後に切断
  }
  */
  var continuation: CheckedContinuation<UInt16, Never>?
  func getBrightness() async -> UInt16 {
    guard let peripheral = targetPeripheral, let characteristic = lightSensorCharacteristic else { return 0 }
    return await withCheckedContinuation { continuation0 in
      continuation = continuation0
      peripheral.readValue(for: characteristic)
    }
  }
  // key
  var funckeydown: ((UInt32) -> Void)?
  var funckeyup: ((UInt32) -> Void)?
  func setKeyDownListener(_ callback: @escaping (UInt32) -> Void) {
    funckeydown = callback
  }
  func setKeyUpListener(_ callback: @escaping (UInt32) -> Void) {
    funckeyup = callback
  }
  func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
    if let error = error {
      print("❌ データ読み取りエラー: \(error.localizedDescription)")
      return
    }
    guard let value = characteristic.value else {
      print("⚠️ データなし")
      return
    }
    
    let number = value.withUnsafeBytes { $0.load(as: UInt16.self).littleEndian }
    if characteristic == keyCharacteristic {
      //print("🔢 keystate: \(String(number, radix: 2))")
      let down = keystate & ~number // 1 -> 0
      let up = ~keystate & number // 0 -> 1
      for i in 0...11 {
        let c = charToUnicode(getCharacter(in: keys, at: i), defvalue: 0)
        if (down & (1 << i)) != 0 {
          //print("key down: \(c)")
          if let f = funckeydown { f(c) }
        } else if (up & (1 << i)) != 0 {
          //print("key up: \(c)")
          if let f = funckeyup { f(c) }
        }
      }
      keystate = number
    } else if characteristic == lightSensorCharacteristic {
      //print("🔢 brightness: \(number)")
      if let c = continuation {
        c.resume(returning: number)
        continuation = nil
      }
    }
  }
}
