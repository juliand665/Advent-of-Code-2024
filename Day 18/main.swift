import AoC_Helpers

let dropCoords = input().lines().map(Vector2.init)
let maxCoord = 70
let start = Vector2(0, 0)
let end = Vector2(maxCoord, maxCoord)
let initialDrops = 1024

func shortestPath(afterDrops drops: Int) -> Int? {
    var map = Matrix(width: maxCoord + 1, height: maxCoord + 1, repeating: false)
    for drop in dropCoords.prefix(drops) {
        map[drop] = true
    }
    
    var explored: Set<Vector2> = []
    var next: Set<Vector2> = [start]
    var distance = 0
    while !next.isEmpty {
        explored.formUnion(next)
        let current = next
        next = current
            .lazy
            .flatMap(\.neighbors)
            .filter { map.element(at: $0) == false }
            .filter { !explored.contains($0) }
            .asSet()
        distance += 1
        if next.contains(end) { return distance }
    }
    return nil
}

print(shortestPath(afterDrops: 1024)!)

// binary search for breaking drop
let searchRange = (1024...dropCoords.count)
let firstBreakingIndex = measureTime {
    searchRange.partitioningIndex { dropCount in
        shortestPath(afterDrops: dropCount) == nil
    }
}
print(dropCoords[searchRange[firstBreakingIndex] - 1])
