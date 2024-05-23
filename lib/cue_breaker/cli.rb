require 'optparse'

require 'cue_breaker/core'
require 'cue_breaker/dependencies'
require 'delegate'

module CueBreaker
  module CLI
    extend self

    def start
      Dependencies.check!

      options = Options.new

      duration = Core.get_audio_duration(options.wav)
      Core.parse_cue(options.cue, duration: duration) do |album, song|
        Core.convert_to_mp3(options.wav, album.present, song.present, options.output)
      end
    end

    class Options < SimpleDelegator
      def initialize
        options = {}

        OptionParser.new do |opt|
          opt.on('-c', '--cue CUEFILE') { |o| options[:cue] = o }
          opt.on('-w', '--wav WAVFILE') { |o| options[:wav] = o }
          opt.on('-o', '--output LASTNAME') { |o| options[:output] = o }
        end.parse!

        super Struct.new(*options.keys).new(*options.values)
      end
    end
  end
end
