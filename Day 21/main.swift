import AoC_Helpers
import HandyOperators
import Algorithms

let chars: [Direction: Character] = [
	.up: "^",
	.right: ">",
	.down: "v",
	.left: "<",
]

let keypad = Matrix([
	"789",
	"456",
	"123",
	" 0A",
])
let arrowKeys = Matrix([
	" ^A",
	"<v>",
])

final class Level {
	let keyPositions: [Character: Vector2]
	let confirmPosition: Vector2
	//let knownCosts: [Vector2: Int] = [:] // by delta
	let previous: Level?
	let forbidden: Vector2
	
	init(keys: Matrix<Character>, previous: Level?) {
		self.keyPositions = keys.indexed.lazy.map { ($1, $0) }.asDictionary()
		self.confirmPosition = keys.onlyIndex(of: "A")!
		self.forbidden = keys.onlyIndex(of: " ")!
		self.previous = previous
	}
	
	// implicitly ending in A
	func presses(for sequence: some Collection<Character>) -> Int {
		presses(for: chain(
			[confirmPosition],
			chain(
				sequence.map { keyPositions[$0]! },
				[confirmPosition]
			)
		))
	}
	
	var memo: [MemoKey: Int] = [:]
	
	func presses(for positions: some Collection<Vector2>) -> Int {
		positions.adjacentPairs().sum { start, end in
			let key = MemoKey(start: start, end: end)
			if let memoized = memo[key] { return memoized }
			
			let delta = end - start
			let horizontal = repeatElement(delta.x > 0 ? Direction.right : .left, count: abs(delta.x))
			let vertical = repeatElement(delta.y > 0 ? Direction.down : .up, count: abs(delta.y))
			
			// computing these lazily speeds things up by 10x!!! what!
			var hFirst: Int { moveCost(for: chain(horizontal, vertical)) }
			var vFirst: Int { moveCost(for: chain(vertical, horizontal)) }
			
			let canGoHFirst = start.with(x: end.x) != forbidden
			guard canGoHFirst else { return vFirst }
			let canGoVFirst = start.with(y: end.y) != forbidden
			guard canGoVFirst else { return hFirst }
			
			return min(hFirst, vFirst) <- { memo[key] = $0 }
		}
	}
	
	func moveCost(for directions: some Collection<Direction>) -> Int {
		if let previous {
			previous.presses(for: directions.lazy.map { chars[$0]! })
		} else {
			directions.count + 1
		}
	}
	
	struct MemoKey: Hashable {
		var start: Vector2
		var end: Vector2
	}
}

let codes = input().lines().map { $0.dropLast() }

func simulate(intermediateLevels: Int) {
	let lastKeys: Level? = repeatElement(arrowKeys, count: intermediateLevels).reduce(nil) {
		Level(keys: $1, previous: $0)
	}
	let level = Level(keys: keypad, previous: lastKeys)
	print(codes.sum { code in
		Int(code)! * level.presses(for: code)
	})
}

simulate(intermediateLevels: 2)
measureTime {
	simulate(intermediateLevels: 25)
}
