import AoC_Helpers
import Foundation

extension Matrix {
    func sequence(from start: Vector2, step: Vector2) -> some Sequence<Element> {
        Swift.sequence(state: start) { pos in
            defer { pos += step }
            return element(at: pos)
        }
    }
}

let grid = Matrix(input().lines())

let matches = grid.positions.map { start in
    [Vector2].distance1orDiagonal.count { step in
        grid.sequence(from: start, step: step).starts(with: "XMAS")
    }
}
print(matches.sum())

let diagonals = [Vector2].distance1orDiagonal.filter { $0.absolute.sum == 2 }
let patterns = ["MMSS", "MSSM", "SSMM", "SMMS"]
let xMatches = grid.positions.count { start in
    grid[start] == "A" && patterns.contains { pattern in
        diagonals
            .compactMap { grid.element(at: start + $0) }
            .elementsEqual(pattern)
    }
}
print(xMatches)
