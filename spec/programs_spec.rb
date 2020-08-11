require './lib/core'

describe "Sample Programs" do

  describe "Sleepy" do

    it "executes the sleepy program" do
    program = [
     Core::Instructions::AddInstruction.new(
       source: Core::Instructions::Operand.new(mode: :immediate, address: 10),
       destination: Core::Instructions::Operand.new(mode: :immediate, address: -1)
     ),
     Core::Instructions::MovInstruction.new(
       source: Core::Instructions::Operand.new(mode: :direct, address: 2),
       destination: Core::Instructions::Operand.new(mode: :b_field_indirect, address: -1)
     ),
     Core::Instructions::JmpInstruction.new(
       source: Core::Instructions::Operand.new(mode: :direct, address: -2),
       destination: Core::Instructions::Operand.new(mode: :direct, address: 0)
     ),
     Core::Instructions::DatInstruction.new(
       source: Core::Instructions::Operand.new(mode: :immediate, address: 33),
       destination: Core::Instructions::Operand.new(mode: :immediate, address: 33)
     )
    ]
    core = Core::VM.new(core_size: 64)
    core.load(Core::Program.new(program, program_id: 1))
    core.boot!
    display = Core::Display.new(core)
    10.times do |i|
      core.execute_cycle()
      display.print
    end
    end

  end

end
