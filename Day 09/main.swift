import AoC_Helpers
import Algorithms

let lengths = Array(input().map { Int(String($0))! })

assert(lengths.count % 2 == 1)
let lastFileID = lengths.count / 2

let blocks: [Int?] = lengths.enumerated().flatMap { (id, length) in
	repeatElement(id % 2 == 0 ? id / 2 : nil, count: length)
}

// part 1
measureTime {
	var blocks = blocks[...]
	var checksum = 0
	while !blocks.isEmpty {
		let position = blocks.startIndex
		if let fileID = blocks.removeFirst() {
			checksum += fileID * position
		} else {
			blocks.trimSuffix { $0 == nil }
			checksum += blocks.removeLast()! * position
		}
	}
	print(checksum)
}

// part 2
measureTime {
	struct Span {
		var length: Int
		var fileID: Int?
		
		func checksum(startingAt position: Int) -> Int {
			guard let fileID else { return 0 }
			return fileID * length * position + fileID * length * (length - 1) / 2
		}
	}
	
	let spans = lengths.enumerated().map { (id, length) in
		Span(length: length, fileID: id % 2 == 0 ? id / 2 : nil)
	}
	
	var spansByStart: [Int: Span] = [:]
	var filePositions: [Int] = []
	do {
		var position = 0
		for span in spans {
			if span.fileID != nil {
				filePositions.append(position)
				spansByStart[position] = span
			}
			position += span.length
		}
	}
	
	// attempt to move each file forward, starting with the highest ID/from the back
	var remainingPositons = filePositions[...]
	while let oldPosition = remainingPositons.popLast() {
		let span = spansByStart[oldPosition]!
		var newPosition = 0
		while newPosition < oldPosition {
			// got space for file?
			let newPositions = newPosition ..< newPosition + span.length
			let existing = newPositions
				.lazy
				.compactMap { position in
					spansByStart[position].map { position + $0.length }
				}
				.first
			if let existing {
				newPosition = existing
			} else {
				// move file
				spansByStart[newPosition] = span
				spansByStart[oldPosition] = nil
				break
			}
		}
	}
	
	let checksum = spansByStart.lazy.map { $1.checksum(startingAt: $0) }.sum()
	print(checksum)
}
