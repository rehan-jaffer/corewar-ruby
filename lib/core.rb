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
    attr_accessor :process_queue, :memory, :core

    def initialize(core, process_queue, memory)
      @core = core
      @process_queue = process_queue
      @memory = memory
    end
  end

  class ExecutionCycle
    def initialize(context)
      @context = context
    end

    def run()
      instruction = fetch_instruction
      case instruction
      when Core::Instructions::MovInstruction
        mov(instruction.source, instruction.destination)
        move_to_next_instruction
      when Core::Instructions::NullInstruction
        kill_current_process
      when Core::Instructions::JmpInstruction
        set_current_program_counter(instruction.source)
      when Core::Instructions::DatInstruction
        kill_current_process
      when Core::Instructions::DummyInstruction
        move_to_next_instruction
      when Core::Instructions::SubInstruction
        sub(instruction.source, instruction.destination)
        move_to_next_instruction
      when Core::Instructions::SplInstruction
        spl(instruction.program_id, instruction.source, instruction.destination)
        move_to_next_instruction
      when Core::Instructions::AddInstruction
        instruction.execute(
          @context.core,
          source: instruction.source,
          destination: instruction.destination,
        )
        move_to_next_instruction
      end
      move_to_next_process
    rescue NoMethodError => e
      move_to_next_process
    rescue StandardError => e
      kill_current_process
      move_to_next_process
    end

    private

    def set_current_program_counter(operand)
      @context.process_queue.set_current(@context.core.translate_address(operand))
    end

    def fetch_instruction
      @context.memory[@context.process_queue.current]
    end

    def move_to_next_instruction
      @context.process_queue.update_program_counter(@context.memory.size)
    end

    def move_to_next_process
      @context.process_queue.update_queue_index
    end

    def kill_current_process
      @context.process_queue.kill(@context.process_queue.current)
    end

    def spl(program_id, source, destination)
      Core::Instructions::SplInstruction.new(context: @context, program_id: program_id).execute(source, destination)
    end

    def sub(source, destination)
      Core::Instructions::SubInstruction.new(context: @context).execute(source, destination)
    end

    def mov(source, destination)
      Core::Instructions::MovInstruction.new(context: @context).execute(source, destination)
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
      context = Core::ExecutionContext.new(self, @process_queue, @memory)
      cycle = Core::ExecutionCycle.new(context)
      cycle.run
      remove_dead_processes
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
      @process_queue.remove_dead_processes(alive: @memory.programs)
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
