import AoC_Helpers
import HandyOperators

let grid = Matrix(input().lines())
let start = grid.onlyIndex(of: "S")!
let end = grid.onlyIndex(of: "E")!
let walls = grid.map { $0 == "#" }

// i should really add a helper for BFS huh
let distances: [Vector2: Int] = [:] <- { distances in
	var toExplore: Set<Vector2> = [start]
	var distance = 0
	while !toExplore.isEmpty {
		for spot in toExplore {
			distances[spot] = distance
		}
		
		toExplore = toExplore
			.lazy
			.flatMap(\.neighbors)
			.filter { !walls[$0] }
			.filter { [distances] in distances[$0] == nil }
			.asSet()
		
		distance += 1
	}
}

let distance = distances[end]!
let sortedDistances = distances.sorted(on: \.value)

func goodSkips(maxLength: Int) -> Int {
	sortedDistances.enumerated().sum { count, near in
		let (start, distance) = near
		return sortedDistances.prefix(count) // anything past here is a higher distance and not worth skipping to
			.lazy
			.filter { $0.key.distance(to: start) <= maxLength }
			.map { skip, farDistance in
				distance - farDistance - skip.distance(to: start)
			}
			.count { $0 >= 100 }
	}
}

print(measureTime { goodSkips(maxLength: 2) })
print(measureTime { goodSkips(maxLength: 20) })
