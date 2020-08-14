module Core
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
end