require './lib/core'

describe "Core Instructions" do 

  describe "MOV" do 

    it "allows creating a program with a MOV instruction" do 

      instruction = Core::Instructions::MovInstruction.new(
          source: Core::Instructions::Operand.new(mode: :direct, address: 0),
          destination: Core::Instructions::Operand.new(mode: :direct, address: 1)
        )
      program = Core::Program.new([instruction], program_id: 1)

    end

    it "executes the imp program directly" do 

        core = Core::VM.new(core_size: 4)
        instruction = Core::Instructions::MovInstruction.new(
            source: Core::Instructions::Operand.new(mode: :direct, address: 0),
            destination: Core::Instructions::Operand.new(mode: :direct, address: 1)
          )
        program = Core::Program.new([instruction], program_id: 1)
        load_address = core.load(program)
        core.boot!(preset_pc: 0)

        4.times do |i|
          core.execute_cycle();
        end

        expect(core.memory[load_address+1].program_id).to eq 1
        
    end

  end

  it "fills the core with the imp instruction if left running" do 

    core = Core::VM.new(core_size: 4)
    instruction = Core::Instructions::MovInstruction.new(
        source: Core::Instructions::Operand.new(mode: :direct, address: 0),
        destination: Core::Instructions::Operand.new(mode: :direct, address: 1)
      )
    program = Core::Program.new([instruction], program_id: 1)
    load_address = core.load(program)
    core.boot!(preset_pc: 0)

    4.times do |i|
      core.execute_cycle();
    end

    expect(core.memory.dump.map(&:class)).to all eq Core::Instructions::MovInstruction

  end

end