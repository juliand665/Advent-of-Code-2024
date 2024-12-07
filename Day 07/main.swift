import AoC_Helpers

struct Equation {
    var result: Int
    var operands: [Int]
}

let equations = input().lines().map {
    let ints = $0.ints()
    return Equation(result: ints.first!, operands: Array(ints.dropFirst()))
}

func canReach(_ result: Int, operands: ArraySlice<Int>) -> Bool {
    let last = operands.last!
    guard operands.count > 1 else {
        return last == result
    }
    let (quotient, remainder) = result.quotientAndRemainder(dividingBy: last)
    if remainder == 0, canReach(quotient, operands: operands.dropLast()) {
        return true
    } else if canReach(result - last, operands: operands.dropLast()) {
        return true
    } else {
        // wanna avoid string conversions if we can help it so i've put this last
        let resultString = String(result)
        let lastString = String(last)
        if resultString.ends(with: lastString) {
            return canReach(Int(resultString.dropLast(lastString.count)) ?? 0, operands: operands.dropLast())
        }
    }
    return false
}

print(equations.filter { canReach($0.result, operands: $0.operands[...]) }.map(\.result).sum())
