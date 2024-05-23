require_relative 'lib/cue_breaker/version'

Gem::Specification.new do |s|
  s.name        = "cue_breaker"
  s.version     = CueBreaker::VERSION
  s.summary     = "Breaks CUE files into mp3s"
  s.description = "Breaks down large CUE/WAV files into mp3 chunks"
  s.authors     = ["Lukas Alexander"]
  s.email       = "the.lukelex@gmail.com"
  s.homepage    = "https://github.com/lukelex/cue_breaker"
  s.license     = "MIT"

  s.bindir      = "bin"
  s.files       = ["lib/cue_breaker.rb"]
  s.files       = Dir["lib/**/*", "bin/*", "README.md", "LICENSE.txt"]
  s.executables   = ["cue_break"]
  s.require_paths = ["lib"]

  # s.add_dependency "rubycue"

  s.add_development_dependency "pry-nav"
  s.add_development_dependency "rspec"
end
