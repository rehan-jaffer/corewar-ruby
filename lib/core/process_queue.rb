module Core
  class ProcessQueue
    def initialize
      @queue = []
      @index = 0
      @programs = []
      @processes = []
    end

    def current
      @queue[@index].program_counter
    end

    def current_process
      @queue[@index]
    end

    def set_current(value)
      @queue[@index].program_counter = value
    end

    def current_process_id
      @index
    end

    def kill(id)
      current_process.alive = false
      @processes = @processes.select { |process| process != current_process.program_id }
    end

    def update_program_counter(memory_size)
      @queue[current_process_id].program_counter = (current + 1) % memory_size
    end

    def update_queue_index
      loop do
        @index = (@index + 1) % (@queue.size)
        break if current_process.alive?
      end
    end

    def add(process)
      @queue.push(process)
      @processes.push(process.program_id)
    end

    def is_alive?(program_id)
      @queue.select { |program| program.alive? }.map(&:program_id).include?(program_id) == true
    end

    def size
      @queue.select { |program| program.alive? }.size
    end
  end
end