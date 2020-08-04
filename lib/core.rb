require_relative "./core/instructions/base_instruction"
require_relative "./core/instructions/null_instruction"
require_relative "./core/instructions/mov_instruction"
require 'colorize'

module Core
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

    def boot!(preset_pc: nil)
      initial_pc = preset_pc || random_memory_location
      @process_queue.add(initial_pc)
    end

    def execute_cycle
      instruction = @memory[@process_queue.current]
      case instruction
      when Core::Instructions::MovInstruction
        instruction.execute(@memory, source: translate_address(instruction.source), destination: translate_address(instruction.destination))
      end
      @process_queue.update_counter(@process_queue.current_process_id, (@process_queue.current + 1) % @memory.size)
    end

    def load(program)
      @memory.load(program)
    end

    def print_cell(cell, active=false)
      if cell.program_id.nil?
        return "#".colorize(:dark_grey) unless active
        return " ".colorize(background: :white)
      end
      return cell.program_id.to_s.colorize(:green) unless active 
      return cell.program_id.to_s.colorize(:black).colorize(background: :white)
    end

    def print
      puts ""
      puts " [ C O R E W A R ] MARS VIRTUAL MACHINE".colorize(:green)
      puts (" CORE DUMP FOLLOWS: [CURRENT PROGRAM COUNTER: #{process_queue.current} [PID: #{process_queue.current_process_id}]").colorize(:green)
      @memory.dump.each.with_index do |cell, idx|
        if (idx % (@memory.size ** 0.5) == 0)
          puts ""
          printf ("0x#{idx.to_s(16).ljust(2, "0")} ".ljust(10, " ")).colorize(:green)
        end
        printf " [  #{print_cell(cell, (process_queue.current == idx))} ] "
      end
      puts ""
    end

    private

    def translate_address(operand)
      case operand.mode
      when :direct
        process_queue.current + operand.address
      end
    end

    def random_memory_location
      (rand() * @memory.size).round
    end
  end

  class Memory
    include Enumerable

    attr_reader :size

    def initialize(size)
      @size = size
      @core = Array.new(size, Core::Instructions::NullInstruction.new)
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

      program_location
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

    def initialize(instructions, program_id:)
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
