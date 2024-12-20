import AoC_Helpers
import Foundation

func isSafe(report: some Sequence<Int>) -> Bool {
	let diffs = report.adjacentPairs().map { $1 - $0 }
	return false
	|| diffs.allSatisfy { (1...3).contains(+$0) } // all gradually increasing
	|| diffs.allSatisfy { (1...3).contains(-$0) } // all gradually decreasing
}

let reports = input().lines().map { $0.ints() }
let safeCount = reports.count(where: isSafe)
print(safeCount)

let safeCountWithSkips = reports.count { report in
	report.indices.contains { skippedIndex in
		isSafe(report: report.prefix(upTo: skippedIndex) + report.suffix(from: skippedIndex + 1))
	}
}
print(safeCountWithSkips)
