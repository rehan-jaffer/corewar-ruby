module Core

    module Instructions
  
      class DatInstruction < BaseInstruction
  
          attr_accessor :source, :destination
      
          def initialize(source: , destination: )
            @source = source
            @destination = destination
          end

          def execute(core, source: , destination: )
          end
    
      end   
  
    end
  
  end
