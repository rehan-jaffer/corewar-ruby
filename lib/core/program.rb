module Core
  class Program
    attr_reader :instructions, :program_id

    def initialize(instructions, program_id:)
      @program_id = program_id
      @instructions = instructions.map do |instruction|
        instruction.program_id = program_id
        instruction
      end
    end

    def bytes
      instructions
    end

    def to_s 
      instructions.map(&:serialize)
    end

    def size
      @instructions.size
    end
  end
end
