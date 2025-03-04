import Foundation

let emb = Macembot()

/*
  51: C
  52: C+
  53: D
  54: D+
  55: E
  56: F
  57: F+
  58: G
  59: G+
  60: A
  61: A+
  62: B
  63: >C
*/
let music = [
  51, 53, 55, -1, 51, 53, 55, -1, 58, 55, 53, 51, 53, 55, 53, -1,
  51, 53, 55, -1, 51, 53, 55, -1, 58, 55, 53, 51, 53, 55, 51, -1,
  58, 58, 55, 58, 60, 60, 58, -1, 55, 55, 53, 53, 51, -1,
];
Timer.scheduledTimer(withTimeInterval: 1.0, repeats: false) { timer in
  let oct = 0
  for n in music {
    if (n >= 0) {
      emb.buzzer(n: n - 12 * oct)
      emb.led(idx: ((n + 1) % 3) + 1, n: true)
      emb.led(idx: (n % 3) + 1, n: false)
    }
    usleep(500 * 1000)
  }
  emb.buzzer(n: 0)
}

RunLoop.main.run()
