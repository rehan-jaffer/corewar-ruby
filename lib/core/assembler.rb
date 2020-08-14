require_relative "./instructions/base_instruction"
require_relative "./instructions/mov_instruction"
require_relative "./instructions/add_instruction"
require_relative "./instructions/dat_instruction"
require_relative "./instructions/jmp_instruction"

module Core
  class Assembler
    def self.load(file)
      file = File.read(file).lines

      file
        .reject { |line| is_comment?(line) }
        .map { |line| parse_line(line) }
        .map { |hash| instruction_from_hash(hash) }
    end

    private

    def self.instruction_from_hash(hash)
      class_type = Object.const_get("Core::Instructions::#{hash[:operation].capitalize}Instruction")
      class_type.new(source: operand_from_address(hash[:source]), destination: operand_from_address(hash[:destination]))
    end

    def self.operand_from_address(original_address)
      mode = original_address.match(/(?<operand>[\#\@\$]+)(?<address>[\-0-9]+)/)
      Core::Instructions::Operand.new(mode: translate_mode(mode[:operand]), address: mode[:address].to_i)
    rescue StandardError => e
      Core::Instructions::NullOperand.new(mode: nil, address: nil)
    end

    def self.translate_mode(mode)
      case mode
      when "#"
        return :immediate
      when "@"
        return :relative
      else
        return :immediate
      end
    end

    def self.parse_line(line)
      operation, rest = line.split(/[ ]+/, 2)
      source, destination = rest.split(",")

      {
        operation: operation.downcase,
        source: source,
        destination: destination,
      }
    end

    def self.is_comment?(line)
      line.match?(/^;/)
    end
  end
end
