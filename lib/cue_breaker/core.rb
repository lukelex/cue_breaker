require 'rubycue'
require 'fileutils'
require 'open3'

require 'cue_breaker/album'
require 'cue_breaker/track'
require 'cue_breaker/ffmpeg_args'

module CueBreaker
  module Core
    extend self

    def parse_cue(cue_file, duration:, &block)
      cue_sheet = RubyCue::Cuesheet.new(File.read(cue_file), duration.to_i)
      cue_sheet.parse!

      album = as_album(cue_sheet)

      cue_sheet.songs.each do |song|
        block.call(album, as_track(song))
      end
    end

    def convert_to_mp3(wav_file, album, track, output_dir)
      output_path = File.join(output_dir, sanitize_file_name(album.title))
      FileUtils.mkdir_p(output_path) unless Dir.exist?(output_path)

      ffmpeger = FFmpegArgs.new(wav_file, album, track)
      system('ffmpeg', *ffmpeger.options(output_path))
      puts "Exported: #{ffmpeger.output_file_path(output_path)}"
    end

    def get_audio_duration(file_path)
      stdout, stderr, status = Open3.capture3(<<~CMD)
        ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 \"#{file_path}\"
      CMD

      raise "Error getting duration: #{stderr}" unless status.success?

      stdout.strip.to_f
    end

    private

    def as_album(cue_sheet)
      Album.new(
        title: cue_sheet.title,
        performer: cue_sheet.songs.first.fetch(:performer),
        genre: cue_sheet.genre,
        total_tracks: cue_sheet.songs.count,
        date: cue_sheet.date
      )
    end

    def as_track(song)
      Track.new(
        title: song.fetch(:title),
        number: song.fetch(:track),
        start: song.fetch(:index).to_s,
        finish: (song.fetch(:index) + song.fetch(:duration)).to_s
      )
    end

    def sanitize_file_name(name)
      name.gsub(%r{[<>:"/\\|?*]}, '')
    end
  end
end
