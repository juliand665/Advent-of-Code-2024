import AoC_Helpers
import Algorithms

let grid = Matrix(input().lines())
var antennas = grid.positions.grouped { grid[$0] }
antennas.removeValue(forKey: ".")

func printUniqueLocations(compute: (Vector2, Vector2, Vector2) -> some Sequence<Vector2>) {
    let antinodeLocations = antennas.values.flatMap {
        $0.pairwiseCombinations().flatMap { first, second in
            compute(first, second, second - first)
        }
    }
    print(Set(antinodeLocations).count(where: grid.isInMatrix(_:)))
}

printUniqueLocations { first, second, delta in
    [first - delta, second + delta]
}

printUniqueLocations { first, second, delta in
    chain(
        sequence(first: first) { $0 - delta }.prefix(while: grid.isInMatrix(_:)),
        sequence(first: second) { $0 + delta }.prefix(while: grid.isInMatrix(_:))
    )
}
