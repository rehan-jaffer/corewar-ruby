module Core
  class Instruction

    attr_accessor :program_id, :tag

    def initialize(tag: nil)
      @tag = tag
    end
  end

  class NullInstruction < Instruction
  end

  class ProcessQueue
    def initialize
      @queue = []
      @index = 0
    end

    def current
      @queue[@index]
    end

    def current_process_id
      @index
    end

    def update_counter(idx, value)
      @queue[idx] = value
    end

    def add(pc)
      @queue.push(pc)
    end

    def size
      @queue.size
    end
  end

  class VM
    attr_reader :memory, :process_queue

    def initialize(core_size:)
      @memory = Memory.new(core_size)
      @process_queue = ProcessQueue.new
    end

    def mem_set(index, instruction)
      @memory[index] = instruction
    end

    def mem_get(index)
      @memory[index]
    end

    def boot!
      initial_pc = random_memory_location
      @process_queue.add(initial_pc)
    end

    def execute_cycle
      instruction = @memory[@process_queue.current]
      @process_queue.update_counter(@process_queue.current_process_id, @process_queue.current + 1)
    end

    def load(program)
      @memory.load(program)
    end

    def print 
      puts ""
      puts " [ C O R E W A R ] MARS VIRTUAL MACHINE"
      puts " CORE DUMP FOLLOWS: "
      @memory.dump.each.with_index do |cell, idx|
        if (idx % (@memory.size**0.5) == 0)
          puts ""
          printf "0x#{idx.to_s(16).ljust(2, "0")} ".ljust(10, " ")
        end
        printf " [  #{cell.program_id || "#"} ] "
      end
      puts ""
    end


    private

    def random_memory_location
      (rand() * @memory.size).round
    end
  end

  class Memory

    include Enumerable

    attr_reader :size

    def initialize(size)
      @size = size
      @core = Array.new(size, NullInstruction.new)
      @program_locations = []
    end

    def []=(index, value)
      raise Core::InvalidInstructionException unless valid_instruction(value)
      @core[index % @size] = value
    end

    def [](index)
      (index < 0) ? @core[@size + index] : @core[index % @size]
    end

    def load(program)

      program_location = nil

      loop do
        program_location = random_memory_location
        break if non_overlapping_memory_location?(program, program_location)
      end

      program.instructions.each.with_index do |instruction, idx|
        @core[program_location + idx] = instruction
      end
    end

    def dump
      @core
    end

    private

    def random_memory_location
      (rand(@size)).round()
    end

    def non_overlapping_memory_location?(program, location)
      instructions = (location..(location + (program.size))).map do |i|
        self[i]
      end
      instructions.map(&:program_id)
      .all? { |inst| inst.nil? }
    end

    def valid_instruction(value)
      true
    end
  end

  class Program
    attr_reader :instructions, :program_id

    def initialize(instructions, program_id: )
      @instructions = instructions.map do |instruction| 
        instruction.program_id = program_id 
        instruction
      end
    end

    def size
      @instructions.size
    end
  end
end
