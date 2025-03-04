import Foundation

let emb = Macembot()

var n = 0
Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { timer in
  let value = n % 2 == 0 ? 0 : 180
  emb.servo(idx: 1, n: value)
  emb.servo(idx: 2, n: value)
  n += 1
  print("\(n): \(value)")
}

RunLoop.main.run()
