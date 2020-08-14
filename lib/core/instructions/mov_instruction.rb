module Core

    module Instructions
  
      class MovInstruction < BaseInstruction
  
          attr_accessor :source, :destination
      
          def initialize(source: , destination: )
            @source = source
            @destination = destination
          end

          def execute(core, source: , destination: )
            core.memory[destination] = core.memory[source]
          end
    
          def code 
            "MOV"
          end          
      end   
  
    end
  
  end
