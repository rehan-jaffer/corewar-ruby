module Core

    module Instructions
  
      class AddInstruction < BaseInstruction
  
          attr_accessor :source, :destination
      
          def initialize(source: , destination: )
            @source = source
            @destination = destination
          end

          def execute(core, source: , destination: )
            case source.mode
            when :direct
              core.memory[destination.address].destination.address += source.address
            when :immediate
              core.memory[core.translate_address(destination)].destination.address += source.address
            else  
              raise StandardError, "Unimplemented #{source.mode}"
            end
          end
    
          def code 
            "ADD"
          end

      end   
  
    end
  
  end
