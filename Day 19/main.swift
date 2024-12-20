import AoC_Helpers
import Algorithms
import HandyOperators

let (towels, patterns) = input().lineGroups().splat { towels, patterns in
	(
		towels.onlyElement()!.components(separatedBy: ", ").sorted(),
		patterns.map(String.init)
	)
}

var memo: [Substring: Int] = [:]
func waysToMake(_ pattern: Substring) -> Int {
	guard !pattern.isEmpty else { return 1 }
	if let ways = memo[pattern] { return ways }
	return towels
		.lazy
		.filter(pattern.hasSuffix(_:))
		.sum { waysToMake(pattern.dropLast($0.count)) }
	<- { memo[pattern] = $0 }
}

let ways = measureTime { towels.map { waysToMake($0[...]) } }
print(ways.count { $0 > 0 })
print(ways.sum())
