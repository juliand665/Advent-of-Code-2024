import AoC_Helpers

let items = input().lineGroups().map { lines in
	(
		isLock: lines.first!.first! == "#",
		heights: Matrix(lines).columns.map { column in
			column.prefix { $0 == column.first! }.count - 1
		}
	)
}

let locks = items.filter { $0.isLock }.map(\.heights)
let keys = items.filter { !$0.isLock }.map(\.heights)

print(locks.sum { lock in
	keys.count { key in
		zip(lock, key).allSatisfy(<=)
	}
})
