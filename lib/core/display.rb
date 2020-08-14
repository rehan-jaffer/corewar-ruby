require "colorize"

module Core
  class Display
    def initialize(core)
      @core = core
      assign_colors_to_programs
    end

    def print
     header + print_core
    end

    private

    def header
      header_string = "\r\n" +
       " [ C O R E W A R ] MARS VIRTUAL MACHINE" + "\r\n" +
       " CORE DUMP FOLLOWS: [CURRENT PROGRAM COUNTER: #{@core.process_queue.current}" +
       "[PID: #{@core.process_queue.current_process_id}]/#{@core.process_queue.size}\r\n"
      header_string.colorize(:green)
    end

    def print_core
      output = ""
      @core.memory.dump.each.with_index do |cell, idx|
        output += print_core_address(idx) if new_core_line(idx)
        output += print_cell(idx, cell)
      end
      output
    end

    def print_cell(idx, cell)
      "[#{cell_contents(cell, (@core.process_queue.current == idx)).colorize(@colors[cell.program_id])}]"
    end

    def cell_contents(cell, active = false)
      return blank_cell unless @core.process_queue.is_alive?(cell.program_id)
      #      return blank_cell if cell.program_id.nil?
      #      if cell.program_id.nil?
      #        return blank_cell unless active
      #        return active_cell
      #      end
      #      return cell unless active
      return cell.program_id.to_s.colorize(:black).colorize(background: :white) if active
      cell.program_id.to_s
    end

    def print_core_address(idx)
      "\r\n0x#{idx.to_s(16).ljust(2, "0")} ".ljust(10, " ").colorize(:green)
    end

    def new_core_line(idx)
      (idx % (@core.memory.size ** 0.5) == 0)
    end

    def active_cell
      "  ".colorize(background: :white)
    end

    def blank_cell
      "  "
    end

    def assign_colors_to_programs
      colors = [:blue, :green, :light_green, :blue]
      programs = @core.memory.dump.map(&:program_id).compact.uniq
      @colors = programs.map.with_index do |program, idx|
        [program, colors[idx % colors.size]]
      end.to_h
    end
  end
end
