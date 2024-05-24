# frozen_string_literal: true

module CueBreaker
  module Dependencies
    extend self

    def check!
      check_ffmpeg_installed!
    end

    private

    def check_ffmpeg_installed!
      return if system("which ffmpeg > /dev/null 2>&1")

      raise "ffmpeg is not installed. Please install it to use this gem."
    end
  end
end
