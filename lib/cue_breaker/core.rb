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
      cue = RubyCue::Cuesheet.new(File.read(cue_file), duration.to_i)
      cue.parse!

      album = Album.new(
        title: cue.title, 
        performer: cue.songs.first.fetch(:performer),
        genre: cue.genre, 
        total_tracks: cue.songs.count, 
        date: cue.date
      )

      cue.songs.each do |song|
        track = Track.new(
          title: song.fetch(:title),
          number: song.fetch(:track),
          start: song.fetch(:index).to_s,
          finish: (song.fetch(:index) + song.fetch(:duration)).to_s,
        )

        block.call(album, track)
      end
    end

    def convert_to_mp3(wav_file, album, track, output_dir)
      track_title = track.title

      output_path = File.join(output_dir, sanitize_file_name(album.performer))
      FileUtils.mkdir_p(output_path) unless Dir.exist?(output_path)

      ffmpeger = FFmpegArgs.new(wav_file, album, track)
      system("ffmpeg", *ffmpeger.arguments(output_path))
      puts "Exported: #{ffmpeger.output_file_path(output_path)}"
    end

    def parse_time(time_str)
      parts = time_str.split(':').map(&:to_f)
      (parts[0] * 60) + parts[1] + (parts[2] / 75.0)
    end

    def sanitize_file_name(name)
      name.gsub(/[<>:"\/\\|?*]/, '')
    end

    def get_audio_duration(file_path)
      ffprobe_command = "ffprobe -v error -show_entries format=duration -of default=noprint_wrappers=1:nokey=1 \"#{file_path}\""

      stdout, stderr, status = Open3.capture3(ffprobe_command)
      if status.success?
        stdout.strip.to_f
      else
        puts "Error getting duration: #{stderr}"
      end
    end
  end
end
