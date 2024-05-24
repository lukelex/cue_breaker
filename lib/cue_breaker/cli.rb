# frozen_string_literal: true

require "optparse"
require "delegate"

require "cue_breaker/version"
require "cue_breaker/core"
require "cue_breaker/dependencies"

module CueBreaker
  module CLI
    extend self

    def start
      Dependencies.check!

      duration = Core.get_audio_duration(options.wav)

      Core.parse_cue(options.cue, duration: duration) do |album, song|
        Core.convert_to_mp3(options.wav, album.present, song.present, options.output)
      end
    end

    private

    def options
      @_options ||= Options.new
    end

    class Options < SimpleDelegator
      def initialize
        options = {}

        OptionParser.new do |parser|
          parser.banner = BANNER

          parser.on("-c", "--cue CUEFILE") { |o| options[:cue] = o }
          parser.on("-w", "--wav WAVFILE") { |o| options[:wav] = o }
          parser.on("-o", "--output OUTPUT") { |o| options[:output] = o }
        end.parse!

        super(Struct.new(*options.keys).new(*options.values))
      end

      BANNER = <<~BANNER.freeze
        cue_break version #{VERSION}
        Usage: cue_break [options]
      BANNER
    end
  end
end
