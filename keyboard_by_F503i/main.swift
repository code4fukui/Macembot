import Foundation
import CoreGraphics

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

let emb = Macembot()

emb.setKeyDownListener(sendTenkeyDown)
emb.setKeyUpListener(sendTenkeyUp)

RunLoop.main.run()
