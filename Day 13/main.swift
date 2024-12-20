import AoC_Helpers

struct ClawMachine {
	var a, b: Vector2
	var prize: Vector2
	
	func minTokensToPrize(prizeOffset: Int = 0) -> Int? {
		let prize = prize + .init(prizeOffset, prizeOffset)
		
		// na * ax + nb * bx == px
		// na * ax == px - nb * bx
		// na == (px - nb * bx) / ax
		
		// na * ay + nb * by == py
		// (px - nb * bx) / ax * ay + nb * by == py
		// px / ax * ay - nb * bx / ax * ay + nb * by == py
		// -nb * bx / ax * ay + nb * by == py - px / ax * ay
		// nb * (-bx / ax * ay + by) == py - px / ax * ay
		// nb == (py - px / ax * ay) / (-bx / ax * ay + by)
		
		// that's math baybee
		
		let px = Double(prize.x)
		let py = Double(prize.y)
		let ax = Double(a.x)
		let ay = Double(a.y)
		let bx = Double(b.x)
		let by = Double(b.y)
		let nb = (py - px / ax * ay) / (-bx * ay / ax + by)
		let na = (px - nb * bx) / ax
		
		let aCount = Int(na.rounded())
		let bCount = Int(nb.rounded())
		guard
			aCount >= 0, bCount >= 0,
			aCount * a + bCount * b == prize
		else { return nil }
		return 3 * aCount + bCount
	}
}

let machines = input().lineGroups().map {
	$0.splat {
		ClawMachine(
			a: $0.ints().splat(Vector2.init),
			b: $1.ints().splat(Vector2.init),
			prize: $2.ints().splat(Vector2.init)
		)
	}
}

print(machines.lazy.compactMap { $0.minTokensToPrize() }.sum())
let part2Offset = 10_000_000_000_000
print(machines.lazy.compactMap { $0.minTokensToPrize(prizeOffset: part2Offset) }.sum())
