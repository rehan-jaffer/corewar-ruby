require './lib/core'

def null_program(size: size)
    0.upto(size-1).map do |i|
      Core::NullInstruction.new(tag: "Instruction #{i}")
    end
  end

core = Core::VM.new(core_size: 64)
program_1 = null_program(size: 16)
program_2 = null_program(size: 16)
core.load(Core::Program.new(program_1, program_id: 1))
core.load(Core::Program.new(program_2, program_id: 2))
core.print
core.boot!