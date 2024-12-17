import AoC_Helpers

struct State {
    var a, b, c: Int
    var program: [Int]
    var instructionPointer = 0
    
    func outputs(a: Int? = nil) -> [Int] {
        var copy = self
        if let a {
            copy.a = a
        }
        return copy.run()
    }
    
    mutating func run() -> [Int] {
        var outputs: [Int] = []
        while instructionPointer < program.count {
            let opcode = program[instructionPointer]
            let operand = program[instructionPointer + 1]
            instructionPointer += 2
            if let output = run(opcode: opcode, operand: operand) {
                outputs.append(output)
            }
        }
        return outputs
    }
    
    private mutating func run(opcode: Int, operand: Int) -> Int? {
        lazy var comboOperand = operand < 4 ? operand : [a, b, c][operand - 4]
        
        switch opcode {
        case 0: // adv
            a >>= comboOperand
        case 1: // bxl
            b ^= operand
        case 2: // bst
            b = comboOperand & 0b111
        case 3: // jnz
            guard a != 0 else { break }
            instructionPointer = operand
        case 4: // bxc
            b ^= c
        case 5: // out
            return comboOperand & 0b111
        case 6: // bdv
            b = a >> comboOperand
        case 7: // cdv
            c = a >> comboOperand
        default:
            fatalError("Unknown opcode \(opcode)")
        }
        return nil
    }
}

let (registers, program) = input().lineGroups().splat { registers, program in
    (registers.map { $0.ints().onlyElement()! }, program.onlyElement()!.ints())
}

let state = State(a: registers[0], b: registers[1], c: registers[2], program: program)

print(state.outputs().map(String.init).joined(separator: ","))
// 2,1,4,0,7,4,0,2,3

/*
 2,4: bst a // b = a & 0b111
 1,7: bxl 7 // b ^= 0b111
 7,5: cdv b // c = a >> b
 0,3: adv 3 // a >>= 3
 4,0: bxc - // b ^= c
 1,7: bxl 7 // b ^= 0b111
 5,5: out b // output(b)
 3,0: jnz 0 // repeat until a == 0
 
 -> repeatedly pop last 3 digits, XOR with 3 digits offset by popped value XOR 0b111, output that
 */

func findInputs(toProduce output: some Collection<Int>, fixedDigits: Int, fixedMask: Int) -> [Int] {
    guard let nextOutput = output.first else { return [fixedDigits] }
    return (0..<8).flatMap { last3 -> [Int] in
        let isCompatible = last3 & fixedMask == fixedDigits & 0b111
        guard isCompatible else { return [] }
        let fixedMask = fixedMask | 0b111 // fix last 3 digits now
        let fixedDigits = fixedDigits | last3
        
        let offset = last3 & 0b111 ^ 0b111
        let requiredValue = (nextOutput ^ last3) << offset
        let requiredMask = 0b111 << offset
        let isNextCompatible = requiredValue & fixedMask == fixedDigits & requiredMask
        guard isNextCompatible else { return [] }
        return findInputs(
            toProduce: output.dropFirst(),
            fixedDigits: (fixedDigits | requiredValue) >> 3,
            fixedMask: (fixedMask | requiredMask) >> 3
        ).map { $0 << 3 | last3 }
    }
}
let inputs = findInputs(toProduce: program, fixedDigits: 0, fixedMask: 0)
    .sorted() // some large values would exceed 64 bits and thus don't work
for input in inputs {
    let outputs = state.outputs(a: input)
    print("input \(input)", outputs == program ? "works" : "doesn't work")
}
print(inputs.first!)
