import AoC_Helpers
import Foundation
import RegexBuilder

let mulRegex = Regex {
	let number = Capture {
		Repeat(1...3) { CharacterClass.digit }
	} transform: {
		Int($0)!
	}
	"mul("
	number
	","
	number
	")"
}

let multiplications = input().matches(of: mulRegex)
print(multiplications.lazy.map { $0.output.1 * $0.output.2 }.sum())

var rest = input()[...]
var isEnabled = true
var sum = 0
while let next = rest.firstMatch(of: mulRegex) {
	let skipped = rest.prefix(upTo: next.range.lowerBound)
	let lastEnable = skipped.lastRange(of: "do()")?.upperBound
	let lastDisable = skipped.lastRange(of: "don't()")?.upperBound
	if let lastEnable, let lastDisable {
		isEnabled = lastEnable > lastDisable
	} else if lastEnable != nil {
		isEnabled = true
	} else if lastDisable != nil {
		isEnabled = false
	}
	
	if isEnabled {
		sum += next.output.1 * next.output.2
	}
	rest = rest.suffix(from: next.range.upperBound)
}
print(sum)

extension BidirectionalCollection where Element: Equatable {
	func lastRange(of search: some BidirectionalCollection<Element>) -> Range<Index>? {
		guard let range = reversed().firstRange(of: search.reversed()) else { return nil }
		return range.upperBound.base..<range.lowerBound.base
	}
}
