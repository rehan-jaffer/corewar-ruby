require "./lib/core"

def null_program(size)
  0.upto(size-1).map do |i|
    Core::Instructions::NullInstruction.new(tag: "Instruction #{i}")
  end
end

describe Core::VM do
  describe "initialization" do
    it "permits creating a new VM" do
      expect { core = Core::VM.new(core_size: 1024) }.not_to raise_error
    end

    it "creates an array with a size based on its initialization" do
      rand_memory_size = 1024 * rand()
      core = Core::VM.new(core_size: rand_memory_size)
      expect(core.memory.size).to eq rand_memory_size
    end
  end

  describe "memory" do
    it "permits setting the elements of the memory" do
      core = Core::VM.new(core_size: 1024)
      core.mem_set(0, Core::Instructions::NullInstruction.new)
    end

    it "allows retrieving elements of the memory" do
      core = Core::VM.new(core_size: 1024)
      core.mem_set(0, Core::Instructions::NullInstruction.new(tag: "tagged instruction"))
      instruction = core.mem_get(0)
      expect(instruction.tag).to eq "tagged instruction"
    end

    it "wraps around when the memory exceeds the stated size" do
      core = Core::VM.new(core_size: 1024)
      core.mem_set(0, Core::Instructions::NullInstruction.new(tag: "tagged instruction"))
      instruction = core.mem_get(1024)
      expect(instruction.tag).to eq "tagged instruction"
    end
  end

  describe "process queue" do
    it "should initially have an empty process queue" do
      core = Core::VM.new(core_size: 1024)
      expect(core.process_queue.size).to eq 0
    end

    it "creates a process queue with a process counter when booted" do
      core = Core::VM.new(core_size: 1024)
      core.boot!
      expect(core.process_queue.size).to eq 1
    end

    it "executes a cycle, updating the process count in the queue" do
      core = Core::VM.new(core_size: 1024)
      core.boot!
      initial_pc = core.process_queue.current
      core.execute_cycle
      expect(core.process_queue.current).to eq initial_pc + 1
    end
  end

  describe "loading programs into memory" do
    it "permits loading a program into the memory" do
      core = Core::VM.new(core_size: 1024)
      program = Core::Program.new(
        null_program(3),
        program_id: 1)
      core.load(program)
      expect(core.memory.dump.map(&:tag).compact).to eq ["Instruction 0", "Instruction 1", "Instruction 2",]
    end

    it "loads the program at a random location in memory" do 
    
#      5.times do |i|
#        core = Core::VM.new(core_size: 1024)
#        program = Core::Program.new([Core::NullInstruction.new(tag: "Instruction #1"), Core::NullInstruction.new(tag: "Instruction #2"), Core::NullInstruction.new(tag: "Instruction #3")])
#        core.load(program)
#      end

    end

    it "loads two programs at non-overlapping portions of memory" do 

        core = Core::VM.new(core_size: 16)
        program_1 = null_program(6)
        program_2 = null_program(6)
        core.load(Core::Program.new(program_1, program_id: 1))
        core.load(Core::Program.new(program_2, program_id: 2))
        memory = core.memory.dump
        expect(memory.map(&:tag).compact.size).to eq 12
     end

  end


end
