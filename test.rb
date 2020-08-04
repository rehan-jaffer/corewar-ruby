require './lib/core'

def null_program(size: size)
    0.upto(size-1).map do |i|
      Core::NullInstruction.new(tag: "Instruction #{i}")
    end
end

def imp_program
    Core::Instructions::MovInstruction.new(
        source: Core::Instructions::Operand.new(mode: :direct, address: 0),
        destination: Core::Instructions::Operand.new(mode: :direct, address: 1)
    )
end

core = Core::VM.new(core_size: 64)
core.load(Core::Program.new([imp_program], program_id: 1))
core.load(Core::Program.new([imp_program], program_id: 2))
core.boot!
100.times do |i|
  core.execute_cycle()
  sleep 0.5
  puts `clear`
  core.print
end
