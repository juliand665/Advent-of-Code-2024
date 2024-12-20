import AoC_Helpers

//let size = Vector2(11, 7)
let size = Vector2(101, 103)
let center = size / 2

struct Robot {
	var position: Vector2
	var velocity: Vector2
}

let robots = input().lines().map {
	$0.ints(allowSigns: true).splat {
		Robot(position: .init($0, $1), velocity: .init($2, $3))
	}
}

func limit(_ pos: Vector2) -> Vector2 {
	Vector2(pos.x %% size.x, pos.y %% size.y)
}

do {
	let positions = robots.map {
		limit($0.position + $0.velocity * 100)
	}
	
	func quadrant(of position: Vector2) -> Int? {
		if position.x == center.x || position.y == center.y { return nil }
		return if position.x < center.x {
			position.y < center.y ? 0 : 1
		} else {
			position.y < center.y ? 2 : 3
		}
	}
	
	let byQuadrants = positions.grouped(by: quadrant(of:))
	print(byQuadrants.filter { $0.key != nil }.map(\.value.count).product())
}

// 31x33 border
let borderSize = Vector2(31, 33)
let borderOffset = Vector2(28, 52)
let borderXs = (borderOffset.x ... borderOffset.x + borderSize.x - 1)
let borderYs = (borderOffset.y ... borderOffset.y + borderSize.y - 1)
let border = Set(
	[]
	+ borderXs.map { Vector2($0, borderYs.lowerBound) }
	+ borderXs.map { Vector2($0, borderYs.upperBound) }
	+ borderYs.map { Vector2(borderXs.lowerBound, $0) }
	+ borderYs.map { Vector2(borderXs.upperBound, $0) }
)

func hasChristmasTree(_ positions: some Sequence<Vector2>) -> Bool {
	border.isSubset(of: positions)
}

do {
	var robots = robots
	var stepSize = 1
	var iteration = 0
	
	while true {
		print()
		print(Matrix(positions: robots.lazy.map(\.position)))
		print("iteration: \(iteration), step size: \(stepSize).")
		switch readLine()! {
		case "m":
			stepSize += 1
		case "l":
			stepSize -= 1
		case "d":
			stepSize *= 2
		case "h":
			stepSize /= 2
		case let other:
			if let int = Int(other) {
				if int > 0 {
					stepSize = int
				} else {
					let target = -int
					robots.forEachMutate {
						$0.position += $0.velocity * (target - iteration)
						$0.position = limit($0.position)
					}
					iteration = target
					continue
				}
			}
		}
		iteration += stepSize
		robots.forEachMutate {
			$0.position += $0.velocity * stepSize
			$0.position = limit($0.position)
		}
	}
	
	for iteration in stride(from: 4, to: .max, by: 101) {
		let positions = robots.map {
			limit($0.position + $0.velocity * iteration)
		}
		print(Matrix(positions: positions))
		if hasChristmasTree(positions) {
			print(iteration)
			break
		}
	}
	
}

// 48383
