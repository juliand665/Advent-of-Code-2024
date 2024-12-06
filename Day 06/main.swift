import AoC_Helpers

let map = Matrix(input().lines())
let start = map.onlyIndex(of: "^")!
let obstacles = Set(map.positions.filter { map[$0] == "#" })

measureTime {
    var position = start
    var direction = Direction.up
    var visited: Set<Vector2> = [start]
    while true {
        visited.insert(position)
        var next: Vector2 { position + direction }
        guard map.isInMatrix(next) else { break }
        while obstacles.contains(next) {
            direction.rotate()
        }
        position = next
    }
    print(visited.count)
}

measureTime {
    struct State: Hashable {
        var position: Vector2
        var direction: Direction
        
        var next: Vector2 { position + direction }
    }
    
    let initial = State(position: start, direction: .up)
    
    var state = initial
    var loopCount = 0
    var visited: Set<Vector2> = []
    var states: Set<State> = [initial] // set of states as we leave each position
    while true {
        visited.insert(state.position)
        guard map.isInMatrix(state.next) else { break }
        while obstacles.contains(state.next) {
            state.direction.rotate()
        }
        
        // what if we placed an obstacle ahead?
        let obstacle = state.next
        if !visited.contains(obstacle) { // would block our path to get here in the first place
            var state = state
            state.direction.rotate()
            var states: Set<State> = states // this speeds up finding loops on average
            while true {
                guard map.isInMatrix(state.next) else { break }
                while state.next == obstacle || obstacles.contains(state.next) {
                    state.direction.rotate()
                }
                guard states.insert(state).inserted else {
                    // loop found!
                    loopCount += 1
                    break
                }
                state.position = state.next
            }
        }
        
        states.insert(state)
        
        state.position = state.next
    }
    print(loopCount) // 1784
}
