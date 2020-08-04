module Core

    module Instructions
  
      class MovInstruction < BaseInstruction
  
          attr_accessor :source, :destination
      
          def initialize(source: , destination: )
            @source = source
            @destination = destination
          end

          def execute(memory, source: , destination: )
            memory[destination] = memory[source]
          end
    
      end   
  
    end
  
  end