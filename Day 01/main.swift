import AoC_Helpers
import Foundation

let (list1, list2) = input().lines().map { $0.ints() }.transposed().splat { ($0, $1) }
let distances = zip(list1.sorted(), list2.sorted()).map { abs($0 - $1) }
print(distances.sum())

let counts = list2.occurrenceCounts()
let scores = list1.map { $0 * counts[$0, default: 0] }
print(scores.sum())
