Gem::Specification.new do |s|
  s.name = %q{Corewar}
  s.version = "0.0.0"
  s.date = %q{2020-08-21}
  s.authors = ["Ray"]
  s.summary = %q{Ruby implementation of Corewar}
  s.files = [
 "lib/core.rb",
 "lib/core/instructions",
 "lib/core/instructions/null_instruction.rb",
 "lib/core/instructions/add_instruction.rb",
 "lib/core/instructions/jmp_instruction.rb",
 "lib/core/instructions/dat_instruction.rb",
 "lib/core/instructions/dummy_instruction.rb",
 "lib/core/instructions/mov_instruction.rb",
 "lib/core/instructions/base_instruction.rb",
 "lib/core/program.rb",
 "lib/core/process_queue.rb",
 "lib/core/display.rb",
 "lib/core/assembler.rb",
 "lib/core/exceptions.rb",
 "lib/core/process.rb",
 "lib/core/memory.rb"]
  s.require_paths = ["lib"]
end
