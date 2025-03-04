import Foundation

let emb = Macembot()

var n = 0
Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
  emb.led(idx: 1, n: n % 2 == 0, brightness: 255)
  n += 1
  print("\(n)")
}

RunLoop.main.run()
