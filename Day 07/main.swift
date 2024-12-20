import AoC_Helpers

struct Equation {
	var result: Int
	var operands: [Int]
}

let equations = input().lines().map {
	let ints = $0.ints()
	return Equation(result: ints.first!, operands: Array(ints.dropFirst()))
}

for isPart2 in [false, true] {
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
		} else if isPart2 {
			// wanna avoid string conversions if we can help it so i've put this last
			let resultString = String(result)
			let lastString = String(last)
			if resultString.ends(with: lastString) {
				guard let prefix = Int(resultString.dropLast(lastString.count)) else { return false }
				return canReach(prefix, operands: operands.dropLast())
			}
		}
		return false
	}
	
	let sum = measureTime { equations
		.lazy
		.filter { canReach($0.result, operands: $0.operands[...]) }
		.map(\.result)
		.sum()
	}
	print(sum)
}
