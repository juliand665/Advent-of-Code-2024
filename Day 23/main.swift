import AoC_Helpers

typealias Node = String

let connections = input().lines().map { $0.components(separatedBy: "-").splat { ($0, $1) } }
let adjacency: [Node: Set<Node>] = connections.reduce(into: [:]) { adjacency, connection in
	adjacency[connection.0, default: []].insert(connection.1)
	adjacency[connection.1, default: []].insert(connection.0)
}

let cliquesOf3: Set<Set<Node>> = adjacency
	.lazy
	.flatMap { node, neighbors in
		neighbors.pairwiseCombinations()
			.lazy
			.filter { adjacency[$0]?.contains($1) == true }
			.map { [node, $0, $1] }
	}
	.asSet()
print(cliquesOf3.count { $0.contains { $0.starts(with: "t") } })

func biggestClique(in nodes: Set<Node>, countToBeat: Int) -> Set<Node> {
	guard nodes.count > 1 else { return nodes }
	
	var remaining = nodes
	var biggest: Set<Node> = []
	for node in nodes {
		let connected = adjacency[node]!.intersection(remaining)
		let countToBeat = max(countToBeat, biggest.count)
		if connected.count + 1 > countToBeat {
			let next = biggestClique(in: connected, countToBeat: countToBeat - 1)
			if next.count > biggest.count - 1 {
				biggest = next.union([node])
			}
		}
		remaining.remove(node)
	}
	return biggest
}
let nodes = Set(adjacency.keys)
let biggest = measureTime { biggestClique(in: nodes, countToBeat: 0) }
print(biggest.sorted().joined(separator: ","))
