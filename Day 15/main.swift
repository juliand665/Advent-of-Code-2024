import AoC_Helpers

let (map, moves) = input().lineGroups().splat {
	(Matrix($0), $1.joined().map { Direction($0)! })
}

do {
	var map = map
	var position = map.onlyIndex(of: "@")!
	map[position] = "."
	
	for direction in moves {
		let line = sequence(first: position) { $0 + direction }
			.prefix { map[$0] != "#" }
		let firstEmpty = line.dropFirst().first { map[$0] == "." }
		if let firstEmpty {
			position += direction.offset
			if position != firstEmpty {
				// moved boxes
				map[position] = "."
				map[firstEmpty] = "O"
			}
		}
	}
	let boxPositions = map.positions(of: "O")
	print(boxPositions.map { $0.x + 100 * $0.y }.sum())
}

do {
	var map = Matrix(map.rows.map { row in
		row.flatMap { char in
			char == "@" ? "@."
			: char == "O" ? "[]"
			: "\(char)\(char)"
		}
	})
	var position = map.onlyIndex(of: "@")!
	map[position] = "."
	
	struct MoveFailedError: Error {}
	
	for direction in moves {
		let isVertical = direction.offset.x == 0
		var copy = map
		func moveAnything(at position: Vector2) throws(MoveFailedError) {
			let next = position + direction
			switch copy[position] {
			case "#":
				throw MoveFailedError()
			case ".":
				break
			case "[":
				try moveAnything(at: next)
				copy[next] = "["
				copy[position] = "."
				if isVertical {
					try moveAnything(at: next + .right)
					copy[next + .right] = "]"
					copy[position + .right] = "."
				}
			case "]":
				try moveAnything(at: next)
				copy[next] = "]"
				copy[position] = "."
				if isVertical {
					try moveAnything(at: next + .left)
					copy[next + .left] = "["
					copy[position + .left] = "."
				}
			default:
				fatalError()
			}
		}
		do {
			try moveAnything(at: position + direction)
			position += direction.offset
			map = copy
		} catch {}
	}
	let boxPositions = map.positions(of: "[")
	print(boxPositions.map { $0.x + 100 * $0.y }.sum())
}
