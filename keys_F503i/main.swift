import Foundation

let emb = Macembot()

func keydown(_ n: UInt32) {
  print("keydown \(n)")
}
func keyup(_ n: UInt32) {
  print("keyup \(n)")
}
emb.setKeyDownListener(keydown)
emb.setKeyUpListener(keyup)

RunLoop.main.run()
