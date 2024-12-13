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
    func explore(from position: Vector2) {
        guard region.insert(position).inserted else { return }
        
        explored.insert(position)
        
        for direction in Direction.allCases {
            let next = position + direction
            if garden.element(at: next) == plant {
                explore(from: next)
            } else {
                perimeter += 1
            }
            
            let front = next
            let right = direction.rotated()
            
            if // concave corner
                garden.element(at: front) != plant,
                garden.element(at: position + right) != plant
            {
                sideCount += 1
            } else if // convex corner
                garden.element(at: front) == plant,
                garden.element(at: position + right) == plant,
                garden.element(at: front + right) != plant
            {
                sideCount += 1
            }
        }
    }
    explore(from: position)
    regions.append(Region(positions: region, perimeter: perimeter, sideCount: sideCount))
    
    //print("region of \(plant) plants has area \(region.count) and perimeter \(perimeter)")
}

print(regions.lazy.map(\.cost).sum())
print(regions.lazy.map(\.discountCost).sum())
