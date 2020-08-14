require './lib/core'

class String
  def fix(size, padstr=' ')
    self[0...size].rjust(size, padstr) #or ljust
  end
end

def random_mode
  [:immediate, :indirect, :relative].shuffle.first
end

def null_program(size: size)
    0.upto(size-1).map do |i|
      Core::NullInstruction.new(tag: "Instruction #{i}")
    end
end

def dwarf_program
      instruction1 = Core::Instructions::AddInstruction.new(
        source: Core::Instructions::Operand.new(mode: :immediate, address: 4),
        destination: Core::Instructions::Operand.new(mode: :relative, address: 1)
      )

      instruction2 = Core::Instructions::MovInstruction.new(
        source: Core::Instructions::Operand.new(mode: :relative, address: 2),
        destination: Core::Instructions::Operand.new(mode: :relative, address: 2)
      )

      instruction3 = Core::Instructions::JmpInstruction.new(
          source: Core::Instructions::Operand.new(mode: :relative, address: -2),
          destination: Core::Instructions::Operand.new(mode: :immediate, address: 0)
      )

      instruction4 = Core::Instructions::DatInstruction.new(
          source: Core::Instructions::Operand.new(mode: :immediate, address: 0),
          destination: Core::Instructions::Operand.new(mode: :immediate, address: 0)
      )

      Core::Program.new([instruction1, instruction2, instruction3, instruction4], program_id: "DW")
end

def imp_program
    Core::Instructions::MovInstruction.new(
        source: Core::Instructions::Operand.new(mode: :relative, address: 0),
        destination: Core::Instructions::Operand.new(mode: :relative, address: 1)
    )
end

def program_name(index)
  index.to_s(16).upcase.fix(2, '0')
end

def random_program()
  instruction = [Core::Instructions::MovInstruction,Core::Instructions::DatInstruction,Core::Instructions::AddInstruction,Core::Instructions::JmpInstruction].shuffle.first
  (1..rand(4)).to_a.map do |i|
    instruction.new(
        source: Core::Instructions::Operand.new(mode: random_mode, address: rand(8) - 4),
        destination: Core::Instructions::Operand.new(mode: random_mode, address: rand(8) - 4)
    )
  end
end

core = Core::VM.new(core_size: 576)

30.times do |i|
  core.load(Core::Program.new(random_program, program_id: program_name(i)))
end

core.load(Core::Program.new([imp_program], program_id: "IP"))
core.load(dwarf_program)

core.boot!

display = Core::Display.new(core)

require 'curses'

Curses.noecho
Curses.init_screen

10000.times do |i|
  core.execute_cycle()
  output = display.print
  Curses.clear()
  Curses.addstr("")
  Curses.refresh
  puts output
  puts ""
  sleep 0.001
end

Curses.close_screen
