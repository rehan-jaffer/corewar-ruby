module Core

    module Instructions
  
      class JmpInstruction < BaseInstruction
  
          attr_accessor :source, :destination
      
          def initialize(source: , destination: )
            @source = source
            @destination = destination
          end

          def execute(core, source: , destination: )
            core.process_queue.set_current(core.memory[source])
          end
    
          def code 
            "JMP"
          end

      end   
  
    end
  
  end
