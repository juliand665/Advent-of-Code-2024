import AoC_Helpers

struct Region {
    var positions: Set<Vector2>
    var perimeter: Int
    var sideCount: Int
    var area: Int { positions.count }
    
    var cost: Int { area * perimeter }
    var discountCost: Int { area * sideCount }
}

let garden = Matrix(input().lines())

var regions: [Region] = []
var explored: Set<Vector2> = []
for position in garden.positions {
    guard !explored.contains(position) else { continue }
    
    let plant = garden[position]
    
    var region: Set<Vector2> = []
    var perimeter = 0
    var sideCount = 0
    var countedForSides: [Direction: Set<Vector2>] = [:]
    func explore(from position: Vector2) {
        guard region.insert(position).inserted else { return }
        
        explored.insert(position)
        
        for direction in Direction.allCases {
            let neighbor = position + direction
            if garden.element(at: neighbor) == plant {
                explore(from: neighbor)
            } else {
                perimeter += 1
                
                if countedForSides[direction]?.contains(position) != true {
                    // explore plants along this side
                    sideCount += 1
                    for clockwise in [true, false] {
                        let offset = direction.rotated(clockwise: clockwise)
                        let side = sequence(first: position) { $0 + offset }.prefix {
                            garden.element(at: $0) == plant && garden.element(at: $0 + direction) != plant
                        }
                        countedForSides[direction, default: []].formUnion(side)
                    }
                }
            }
        }
    }
    explore(from: position)
    regions.append(Region(positions: region, perimeter: perimeter, sideCount: sideCount))
    
    //print("region of \(plant) plants has area \(region.count) and perimeter \(perimeter)")
}

print(regions.lazy.map(\.cost).sum())
print(regions.lazy.map(\.discountCost).sum())
