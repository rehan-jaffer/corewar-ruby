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
      p = find_process_by_id(id) || current_process
      p.alive = false
      remove_from_process_list(id)
    end

    def remove_dead_processes(alive: [])
      @queue.each do |process| 
        if !alive.include?(process.program_id)
          process.alive = false
        end
      end
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

  private 

  def find_process_by_id(id)
    @queue.find { |p| p.program_id == id }
#      current_process.alive = false
  end

  def remove_from_process_list(id)
    @processes = @processes.select { |process| process != id }
  end

end