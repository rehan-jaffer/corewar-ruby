module Core

  module Instructions

    class Operand

      attr_accessor :mode, :address

      def initialize(mode:, address: )
        @mode = mode 
        @address = address
      end
    end

    class BaseInstruction

        attr_accessor :program_id, :tag
    
        def initialize(tag: nil)
          @tag = tag
        end
  
    end   

  end

end