import AoC_Helpers

let heights = Matrix(digitsOf: input().lines())
let starts = heights.positions(of: 0)

func findPeaks(from start: Vector2) -> Int {
    var next: Set = [start]
    for height in heights[start] + 1 ... 9 {
        next = Set(next.flatMap(\.neighbors).filter { heights.element(at: $0) == height })
    }
    return next.count
}

print(starts.lazy.map(findPeaks).sum())

func findTrails(from start: Vector2) -> Int {
    let nextHeight = heights[start] + 1
    guard nextHeight < 10 else { return 1 }
    return start.neighbors.lazy.filter { heights.element(at: $0) == nextHeight }.map(findTrails(from:)).sum()
}

print(starts.lazy.map(findTrails).sum())
