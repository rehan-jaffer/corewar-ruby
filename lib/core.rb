require_relative "./core/instructions/base_instruction"
require_relative "./core/instructions/null_instruction"
require_relative "./core/instructions/mov_instruction"
require_relative "./core/instructions/add_instruction"
require_relative "./core/instructions/jmp_instruction"
require_relative "./core/instructions/dat_instruction"
require_relative "./core/instructions/dummy_instruction"
require_relative "./core/memory"
require_relative "./core/program"
require_relative "./core/exceptions"
require "colorize"

class String
  def fix(size, padstr = " ")
    self[0...size].rjust(size, padstr) #or ljust
  end
end

module Core
  class EmptyCoreException < StandardError
  end

  class Process
    attr_accessor :program_id, :program_counter, :alive

    def initialize(program_id:, program_counter:)
      @program_id = program_id
      @program_counter = program_counter
      @alive = true
    end

    def alive?
      @alive
    end

    def kill!
      @alive = false
    end
  end

  class ProcessQueue
    def initialize
      @queue = []
      @index = 0
      @programs = []
      @processes = []
    end

    def current
      @queue[@index].program_counter
    end

    def current_process
      @queue[@index]
    end

    def set_current(value)
      @queue[@index].program_counter = value
    end

    def current_process_id
      @index
    end

    def kill(id)
      current_process.alive = false
      @processes = @processes.select { |process| process != current_process.program_id }
    end

    def update_program_counter(memory_size)
      @queue[current_process_id].program_counter = (current + 1) % memory_size
    end

    def update_queue_index
      loop do
        @index = (@index + 1) % (@queue.size)
        break if current_process.alive?
      end
    end

    def add(process)
      @queue.push(process)
      @processes.push(process.program_id)
    end

    def is_alive?(program_id)
      @queue.select { |program| program.alive? }.map(&:program_id).include?(program_id) == true
    end

    def size
      @queue.select { |program| program.alive? }.size
    end
  end

  class Display

    def initialize(core)
      @core = core
      assign_colors
    end

    def print_cell(cell, active = false)
      return "  " unless @core.process_queue.is_alive?(cell.program_id)
      if cell.program_id.nil?
        return "  ".colorize(:dark_grey) unless active
        return "  ".colorize(background: :white)
      end
      return cell.program_id.to_s.colorize(:green) unless active
      return cell.program_id.to_s.colorize(:black).colorize(background: :white)
    end

    def print
      output = "\r\n"
      output += " [ C O R E W A R ] MARS VIRTUAL MACHINE".colorize(:green) + "\r\n"
      output += (" CORE DUMP FOLLOWS: [CURRENT PROGRAM COUNTER: #{@core.process_queue.current} [PID: #{@core.process_queue.current_process_id}]/#{@core.process_queue.size}").colorize(:green) + "\r\n"
      @core.memory.dump.each.with_index do |cell, idx|
        if (idx % (@core.memory.size ** 0.5) == 0)
          output += "\r\n"
          output += ("0x#{idx.to_s(16).ljust(2, "0")} ".ljust(10, " ")).colorize(:green)
        end
        output += "[#{print_cell(cell, (@core.process_queue.current == idx)).colorize(@colors[cell.program_id])}]"
      end
      output += "\r\n"
      output
    end

    private
      def assign_colors
        colors = [:blue, :green, :light_green, :blue]
        programs = @core.memory.dump.map(&:program_id).compact.uniq
        @colors = programs.map.with_index do |program, idx|
          [program, colors[idx % colors.size]]
        end.to_h
      end 
  end

  class VM
    attr_reader :memory, :process_queue, :execution_log

    def initialize(core_size:)
      @memory = Memory.new(core_size)
      @process_queue = ProcessQueue.new
      @execution_log = []
    end

    def boot!(preset_pc: nil)
      raise EmptyCoreException if @process_queue.size == 0
    end

    def execute_cycle
      instruction = @memory[@process_queue.current]
      case instruction
      when Core::Instructions::MovInstruction
        instruction.execute(
          self,
          source: translate_address(instruction.source),
          destination: translate_address(instruction.destination),
        )
        @process_queue.update_program_counter(@memory.size)
      when Core::Instructions::NullInstruction
        @process_queue.kill(@process_queue.current)
      when Core::Instructions::JmpInstruction
        @process_queue.set_current(translate_address(instruction.source))
      when Core::Instructions::DatInstruction
        @process_queue.kill(@process_queue.current)
      when Core::Instructions::DummyInstruction
        # do nothing
        @process_queue.update_program_counter(@memory.size)
      when Core::Instructions::AddInstruction
        instruction.execute(
          self,
          source: instruction.source,
          destination: instruction.destination,
        )
        @process_queue.update_program_counter(@memory.size)
      end
      remove_dead_processes
      @process_queue.update_queue_index
    rescue NoMethodError => e
      @process_queue.update_queue_index
    rescue StandardError => e
      @process_queue.kill(@process_queue.current)
      @process_queue.update_queue_index
    end

    def load(program)
      program_memory_location = @memory.load(program)
      @process_queue.add(Core::Process.new(program_counter: program_memory_location, program_id: program.program_id))
      program_memory_location
    end

    def translate_address(operand)
      case operand.mode
      when :relative
        process_queue.current + operand.address
      when :immediate
        operand.address
      when :indirect
        @memory[operand.address].source.address
      else
        raise Core::InvalidAddressingModeException, "Can't access #{operand.mode}"
      end
    end

    private

    def remove_dead_processes

    end

    def log(instruction)
      @execution_log.push(" [#{process_queue.current}] " + instruction.serialize)
    end

    def fetch(operand)
      case operand.mode
      when :immediate
        return operand.address
      else
        return @memory[translate_address(operand)]
      end
    end

    def random_memory_location
      (rand() * @memory.size).round
    end
  end
end
