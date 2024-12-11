import AoC_Helpers
import HandyOperators

func blink(stone: Int) -> [Int] {
    guard stone != 0 else { return [1] }
    let digits = stone.digits()
    if digits.count.isMultiple(of: 2) {
        let half = digits.count / 2
        return [Int(digits: digits.prefix(half)), Int(digits: digits.suffix(half))]
    } else {
        return [stone * 2024]
    }
}

struct MemoKey: Hashable {
    var blinks: Int
    var stone: Int
}

var knownCounts: [MemoKey: Int] = [:]
func stonesAfter(blinks: Int, of stone: Int) -> Int {
    guard blinks > 0 else { return 1 }
    let key = MemoKey(blinks: blinks, stone: stone)
    if let count = knownCounts[key] { return count }
    return blink(stone: stone).lazy.map { stonesAfter(blinks: blinks - 1, of: $0) }.sum() <- {
        knownCounts[key] = $0
    }
}

let initial = input().ints()
measureTime {
    print(initial.lazy.map { stonesAfter(blinks: 25, of: $0) }.sum())
}
measureTime {
    print(initial.lazy.map { stonesAfter(blinks: 75, of: $0) }.sum())
}
