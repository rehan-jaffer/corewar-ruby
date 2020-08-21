module Core
  module Instructions
    class Operand
      attr_accessor :mode, :address

      def initialize(mode:, address:)
        @mode = mode
        @address = address
      end
    end

    class NullOperand
      attr_accessor :mode, :address

      def initialize(mode:, address:)
        @mode = nil
        @address = 0
      end
    end

    class BaseInstruction
      attr_accessor :program_id, :tag, :source, :destination, :context

      def initialize(tag: nil, source: nil, destination: nil, program_id: nil)
        @tag = tag
        @source = source
        @destination = destination
      end

      def serialize
        "#{self.code} #{addressing_mode(source.mode)}#{source.address} #{addressing_mode(destination.mode)}#{destination.address}"
      end

      def execute(source, destination)
        self.send(source.mode, source, destination)
      end

      def code
        "UNIMPLEMENTED"
      end

      def addressing_mode(mode)
        case mode
        when :direct
          "$"
        when :immediate
          "#"
        when :relative
          "@"
        end
      end
    end

    class SplInstruction < BaseInstruction
      def initialize(context: nil, program_id: nil, source: nil, destination: nil)
        @context = context
        @program_id = program_id
        @source = source 
        @destination = destination
      end

      private

      def direct(source, destination)
        @context.process_queue.add(Core::Process.new(program_counter: source.address, program_id: @program_id))
      end

      def immediate(source, destination)
        @context.process_queue.add(Core::Process.new(program_counter: @context.memory[@context.core.translate_address(source)].source.address, program_id: @program_id))
      end

      def relative(source, destination)
        @context.process_queue.add(Core::Process.new(program_counter: @context.process_queue.current + source.address, program_id: @program_id))
      end
    end

    class SubInstruction < BaseInstruction
      def initialize(context)
        @context = context
      end

      private

      def direct(source, destination)
        context.memory[destination.address].destination.address -= source.address
      end

      def immediate
        context.core.memory[context.core.translate_address(destination)].destination.address -= source.address
      end
    end
  end
end
