import Foundation

let emb = Macembot()

func asyncTask() async {
  let n = await emb.getBrightness()
  print("brightness: \(n)")
}

Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
  Task { await asyncTask() }
}

RunLoop.main.run()
