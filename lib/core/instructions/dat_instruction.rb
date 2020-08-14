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

          def code 
            "DAT"
          end
    
      end   
  
    end
  
  end
