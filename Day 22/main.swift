import AoC_Helpers
import Algorithms

typealias Secret = Int
func iterate(_ secret: Secret) -> Secret {
	var secret = secret
	secret ^= secret << 6 // * 64
	secret &= 0xFF_FF_FF
	secret ^= secret >> 5 // / 32
	// pruning here does nothing
	secret ^= secret << 11 // * 2048
	secret &= 0xFF_FF_FF
	return secret
}

let seeds = input().lines().map { Secret($0)! }
let secrets = seeds.map { seed in
	(0..<2000).reductions(seed) { secret, _ in iterate(secret) }
}
print(secrets.sum(of: \.last!))

// convert sequences of deltas to ints by treating them as digits of a base-19 number
let diffRange = (-9...9)
func diffSequenceInt(_ sequence: some Sequence<Int>) -> Int {
	Int(digits: sequence.lazy.map { $0 - diffRange.lowerBound }, base: diffRange.count)
}

struct Buyer {
	var prices: [Int]
	var deltas: [Int]
	var sequencePrices: [Int: Int]
	
	init(prices: [Int]) {
		self.prices = prices
		self.deltas = prices.adjacentPairs().map { $1 - $0 }
		let sequences = deltas.windows(ofCount: 4).lazy.map(diffSequenceInt)
		self.sequencePrices = sequences.enumerated().reduce(into: [:]) { ends, next in
			let (index, sequence) = next
			guard ends[sequence] == nil else { return }
			ends[sequence] = prices[index + 4]
		}
	}
}

measureTime {
	let buyers = secrets.map { Buyer(prices: $0.map { $0 % 10 }) }
	let revenues: [Int: Int] = buyers.reduce(into: [:]) { revenues, buyer in
		for (sequence, price) in buyer.sequencePrices {
			revenues[sequence, default: 0] += price
		}
	}
	print(revenues.values.max()!)
}
