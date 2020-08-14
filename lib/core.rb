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
require_relative "./core/display"
require_relative "./core/process_queue"
require_relative "./core/process"

module Core

  class ExecutionContext 
    attr_accessor :process_queue, :memory
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

    def current_context 
      Core::ExecutionContext.new(process_queue, memory)
    end

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
