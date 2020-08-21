module Core

    module Instructions
  
      class MovInstruction < BaseInstruction
  
          attr_accessor :source, :destination, :context
      
          def initialize(context: nil, source: nil, destination: nil)
            @context = context
            @source = source
            @destination = destination
          end

          def code 
            "MOV"
          end          

          private 

          def indirect(source, destination)
            @context.memory[destination.address] = @context.memory[@context.core.translate_address(source)]
          end

          def immediate(source, destination)
            @context.memory[destination.address] = @context.memory[@context.core.translate_address(source)]
          end

          def relative(source, destination)
            @context.memory[@context.process_queue.current + destination.address] = @context.memory[@context.core.translate_address(source)]
          end

          def direct(source, destination)
            @context.memory[destination.address] = @context.memory[@context.core.translate_address(source)]
          end

      end   
  

    end
  
  end
