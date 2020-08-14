module Core

  module Instructions

    class Operand

      attr_accessor :mode, :address

      def initialize(mode:, address: )
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

        attr_accessor :program_id, :tag
    
        def initialize(tag: nil)
          @tag = tag
        end

        def serialize
          "#{self.code} #{addressing_mode(source.mode)}#{source.address} #{addressing_mode(destination.mode)}#{destination.address}"
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

 end

end
