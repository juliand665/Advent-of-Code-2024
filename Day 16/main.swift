import AoC_Helpers
import HeapModule

let maze = Matrix(input().lines())
let paths = maze.map { $0 != "#" }
let start = maze.onlyIndex(of: "S")!
let end = maze.onlyIndex(of: "E")!

struct Location: Hashable {
    var position: Vector2
    var facing: Direction
    
    var next: Self {
        .init(position: position + facing, facing: facing)
    }
    
    var prev: Self {
        .init(position: position - facing.offset, facing: facing)
    }
    
    func rotated(clockwise: Bool) -> Self {
        .init(position: position, facing: facing.rotated(clockwise: clockwise))
    }
}

struct State: Comparable {
    var location: Location
    var score: Int
    
    static func < (lhs: Self, rhs: Self) -> Bool {
        lhs.score < rhs.score
    }
}

var toExplore: Heap<State> = [.init(location: .init(position: start, facing: .right), score: 0)]
var minScore: [Location: Int] = [:]
while let state = toExplore.popMin() {
    guard minScore[state.location] == nil else { continue }
    minScore[state.location] = state.score
    guard state.location.position != end else { continue }
    
    let next = state.location.next
    if paths[next.position] {
        toExplore.insert(.init(location: next, score: state.score + 1))
    }
    
    for clockwise in [false, true] {
        toExplore.insert(.init(
            location: state.location.rotated(clockwise: clockwise),
            score: state.score + 1000
        ))
    }
}
let bestNorth = minScore[.init(position: end, facing: .up)] ?? .max
let bestEast = minScore[.init(position: end, facing: .right)] ?? .max
let best = min(bestNorth, bestEast)
print(best)

func descend(from state: State) -> Set<Vector2> {
    let location = state.location
    guard location != .init(position: start, facing: .right) else { return [start] }
    let prev = [
        State(location: location.rotated(clockwise: false), score: state.score - 1000),
        State(location: location.rotated(clockwise: true), score: state.score - 1000),
        State(location: location.prev, score: state.score - 1),
    ]
    return prev
        .lazy
        .filter { minScore[$0.location] == $0.score }
        .map { descend(from: $0) }
        .reduce(into: [location.position]) { $0.formUnion($1) }
}
let bestPath = Set([Direction.up, .right].flatMap { endFacing in
    descend(from: .init(location: .init(position: end, facing: endFacing), score: best))
})
print(bestPath.count)
