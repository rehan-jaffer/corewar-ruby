require './lib/core'

describe "Core Instructions" do 

  describe "MOV" do 

    it "allows creating a program with a MOV instruction" do 

      instruction = Core::Instructions::MovInstruction.new(
          source: Core::Instructions::Operand.new(mode: :relative, address: 0),
          destination: Core::Instructions::Operand.new(mode: :relative, address: 1)
        )
      program = Core::Program.new([instruction], program_id: 1)

    end

    it "executes the imp program directly" do 

        core = Core::VM.new(core_size: 4)
        instruction = Core::Instructions::MovInstruction.new(
            source: Core::Instructions::Operand.new(mode: :relative, address: 0),
            destination: Core::Instructions::Operand.new(mode: :relative, address: 1)
        )
        program = Core::Program.new([instruction], program_id: 1)
        load_address = core.load(program)
        core.boot!

        4.times do |i|
          core.execute_cycle();
        end

        expect(core.memory[load_address+1].program_id).to eq 1
        
    end

  end

  it "fills the core with the imp instruction if left running" do 

    core = Core::VM.new(core_size: 4)
    instruction = Core::Instructions::MovInstruction.new(
        source: Core::Instructions::Operand.new(mode: :relative, address: 0),
        destination: Core::Instructions::Operand.new(mode: :relative, address: 1)
      )
    program = Core::Program.new([instruction], program_id: 1)
    load_address = core.load(program)
    core.boot!

    5.times do |i|
      core.execute_cycle();
    end

    expect(core.memory.dump.map(&:class)).to all eq Core::Instructions::MovInstruction

  end

  describe "dwarf program" do

    xit "successfully executes the dwarf program" do

      instruction1 = Core::Instructions::AddInstruction.new(
        source: Core::Instructions::Operand.new(mode: :immediate, address: 11),
        destination: Core::Instructions::Operand.new(mode: :relative, address: 1)
      )

      instruction2 = Core::Instructions::MovInstruction.new(
        source: Core::Instructions::Operand.new(mode: :relative, address: 2),
        destination: Core::Instructions::Operand.new(mode: :relative, address: 3)
      )

      instruction3 = Core::Instructions::JmpInstruction.new(
          source: Core::Instructions::Operand.new(mode: :relative, address: -2),
          destination: Core::Instructions::Operand.new(mode: :immediate, address: 0)
      )

      instruction4 = Core::Instructions::DatInstruction.new(
          source: Core::Instructions::Operand.new(mode: :immediate, address: 0),
          destination: Core::Instructions::Operand.new(mode: :immediate, address: 0)
      )

      dwarf_program = Core::Program.new([instruction1, instruction2, instruction3, instruction4], program_id: 1)
      core = Core::VM.new(core_size: 64)
      core.load(dwarf_program)
      core.boot!
      display = Core::Display.new(core)

      32.times do |i|
        core.execute_cycle()
        puts display.print
      end

    end

  end

end
