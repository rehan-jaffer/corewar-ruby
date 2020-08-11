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

        def serialize
          "#{self.class} #{addressing_mode(source)}#{source.address} #{addressing_mode(destination)}#{destination.address}"
        end

        private

          def addressing_mode(mode)
            case mode
              when :direct
                "$"
              when :immediate
                "#"
              when :relative
                ""
            end
         end

     end

 end

end
