import AoC_Helpers
import HandyOperators

enum Operation: String {
	case and = "AND"
	case or = "OR"
	case xor = "XOR"
	
	func evaluate(_ a: Bool, _ b: Bool) -> Bool {
		switch self {
		case .and: return a && b
		case .or: return a || b
		case .xor: return a != b
		}
	}
}

struct Transform: Equatable {
	var a, b: String
	var out: String
	var op: Operation
	
	var inputs: Set<String> { [a, b] }
}

let (constants, transforms) = input().lineGroups().splat { values, transforms in
	(
		values.map { $0.components(separatedBy: ": ").splat { ($0, $1 == "1") } },
		transforms.map {
			$0.components(separatedBy: " ").splat { a, op, b, _, c in
				Transform(a: min(a, b), b: max(a, b), out: c, op: .init(rawValue: op)!)
			}
		}
	)
}

let transformsByOutput = transforms.lazy.map { ($0.out, $0) }.asDictionary()
let transformsByInput = transforms.grouped(by: \.inputs)
var values: [String: Bool] = constants.asDictionary()
func evaluate(_ out: String) -> Bool {
	values[out] ?? {
		let transform = transformsByOutput[out]!
		return transform.op.evaluate(evaluate(transform.a), evaluate(transform.b))
	}() <- { values[out] = $0 }
}

let outputs = transformsByOutput.keys.filter { $0.starts(with: "z") }.sorted()
//print(outputs)
print(Int(bits: outputs.reversed().lazy.map(evaluate)))

// for each digit:
// halfOut = a ^ b
// halfCarry = a & b
// if first: combinedCarry = halfCarry, fullOut = halfOut
// fullOut = halfOut ^ prevCarry
// fullCarry = halfCarry & prevCarry
// combinedCarry = fullCarry | halfCarry

/// - returns: if failed, any likely suspect registers involved in the chain of transforms
func check(_ outputs: some Collection<String>, carry: String?, swaps: inout [String: String]) -> [String]? {
	func new(_ output: String) -> String {
		swaps[output] ?? output
	}
	
	func force(_ output: String, toEqual correctOutput: String) -> Bool {
		guard output != correctOutput else { return true }
		guard !swaps.keys.contains(output), !swaps.keys.contains(correctOutput) else { return false }
		swaps[output] = correctOutput
		swaps[correctOutput] = output
		return true
	}
	
	guard let output = outputs.first.map(new) else { return nil } // done
	guard outputs.count > 1 else { return nil } // HACK: consider this done for now
	
	let ordinal = output.dropFirst()
	let x = "x\(ordinal)"
	let y = "y\(ordinal)"
	
	let newCarry: String
	
	let fullOut = transformsByOutput[output]!
	if let prevCarry = carry { // not first (LSB) digit
		guard
			let halfOps = transformsByInput[[x, y]],
			let halfOut = halfOps.onlyElement(where: { $0.op == .xor }),
			let halfCarry = halfOps.onlyElement(where: { $0.op == .and })
		else { return [x, y] }
		guard
			let fullOps = transformsByInput[[new(halfOut.out), prevCarry]],
			let fullOut = fullOps.onlyElement(where: { $0.op == .xor }),
			let fullCarry = fullOps.onlyElement(where: { $0.op == .and })
		else { return [halfOut.out, prevCarry] }
		guard
			force(fullOut.out, toEqual: output),
			let combinedCarry = transformsByInput[[new(fullCarry.out), new(halfCarry.out)]]?.onlyElement(),
			combinedCarry.op == .or
		else { return [fullCarry.out, halfCarry.out] }
		newCarry = new(combinedCarry.out)
	} else { // first (LSB) digit
		guard
			fullOut.a == x,
			fullOut.b == y,
			fullOut.op == .xor,
			let ops = transformsByInput[[x, y]],
			let carry = ops.onlyElement(where: { $0.op == .and }),
			let out = ops.onlyElement(where: { $0.op == .xor }),
			force(out.out, toEqual: output)
		else { return [] }
		newCarry = new(carry.out)
	}
	
	var usedSwaps = swaps
	if let suspects = check(outputs.dropFirst(), carry: newCarry, swaps: &usedSwaps) {
		// try out some swaps
		//print("conflict discovered for output \(output) with swaps \(swaps)")
		if suspects.isEmpty {
			print("no suspects for output \(output) with swaps \(swaps)")
			return []
		} else {
			print("conflict discovered for output \(output) on \(suspects) with swaps \(swaps)")
			for suspect in suspects where !swaps.keys.contains(suspect) {
				for other in transformsByOutput.keys where !swaps.keys.contains(other) && suspect != other {
					var newSwaps = usedSwaps
					newSwaps[suspect] = other
					newSwaps[other] = suspect
					//print("trying with swaps \(newSwaps)")
					if check(outputs.dropFirst(), carry: newCarry, swaps: &newSwaps) == nil {
						swaps = newSwaps
						return nil
					}
				}
			}
			return suspects
		}
	} else {
		swaps = usedSwaps
		return nil
	}
}

measureTime {
	var swaps: [String: String] = [:]
	// funnily enough it doesn't work if i provide my answer from the start, but it produces this answer perfectly fine from scratch
	//var swaps = ["z39": "qsb", "gjc": "qjj", "wmp": "z17", "z26": "gvm", "gvm": "z26", "qjj": "gjc", "z17": "wmp", "qsb": "z39"]
	print(check(outputs, carry: nil, swaps: &swaps) as Any)
	//print(swaps)
	print(swaps.keys.sorted().joined(separator: ","))
}
