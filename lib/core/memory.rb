module Core
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
        # instruction.program_id = program.program_id
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

  class Cell 

    attr_accessor :operand, :a, :b

    def initialize(operand, a, b) 
      @operand = operand 
      @a = a 
      @b = b
    end

    def [](index)
      raise Core::InvalidIndexException if index > 2
      case index 
      when 0
        return @operand
      when 1 
        return @a 
      when 2 
        return @b
      end
    end

  end
end
