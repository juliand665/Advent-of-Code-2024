import AoC_Helpers
import Foundation

struct Rule {
	var first: Int
	var second: Int
	
	func isSatisfied(by update: [Int]) -> Bool {
		guard
			let firstIndex = update.firstIndex(of: first),
			let secondIndex = update.firstIndex(of: second)
		else { return true }
		return firstIndex < secondIndex
	}
}

let (rawRules, rawUpdates) = input().lineGroups().splat { ($0, $1) }
let rules = rawRules.map { $0.ints().splat(Rule.init) }
let updates = rawUpdates.map { $0.ints() }

let correctUpdates = updates.filter { update in
	rules.allSatisfy { $0.isSatisfied(by: update) }
}
print(correctUpdates.map { $0[$0.count / 2] }.sum())

let incorrectUpdates = updates.filter { update in
	!rules.allSatisfy { $0.isSatisfied(by: update) }
}
let rulesByFirst = rules.grouped(by: \.first)
let fixedUpdates = incorrectUpdates.map { update in
	update.sorted { lhs, rhs in
		rulesByFirst[lhs, default: []].contains { $0.second == rhs }
	}
}
print(fixedUpdates.map { $0[$0.count / 2] }.sum())
