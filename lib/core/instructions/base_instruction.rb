module Core

  module Instructions

    class BaseInstruction

        attr_accessor :program_id, :tag
    
        def initialize(tag: nil)
          @tag = tag
        end
  
    end   

  end

end