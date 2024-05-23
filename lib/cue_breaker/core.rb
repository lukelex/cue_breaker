require 'rubycue'
require 'fileutils'
require 'open3'

module CueBreaker
  module Core
    extend self

    def parse_cue(cue_file, duration:, &block)
      cue = RubyCue::Cuesheet.new(File.read(cue_file), duration.to_i)
      cue.parse!

      songs = cue.songs.map do |song, index|
        song.merge({
          start: song.fetch(:index).to_s,
          end: (song.fetch(:index) + song.fetch(:duration)).to_s,
        })
      end

      album = Struct
        .new(:name, :genre, :total_tracks, :year)
        .new(cue.title, cue.genre, cue.songs.count, cue.date)

      songs.each { |song| block.call(album, song) }
    end

    def convert_to_mp3(wav_file, album, track, output_dir)
      start_time = parse_time(track[:start])
      end_time = track[:end] ? parse_time(track[:end]) : nil
      track_title = sanitize_file_name(track[:title])
      performer = sanitize_file_name(track[:performer])
      genre = sanitize_file_name(album.genre)
      output_path = File.join(output_dir, track[:performer])
      output_file_path = File.join(output_path, "#{format('%02d', track[:track])} - #{track_title}.mp3")

      FileUtils.mkdir_p(output_path) unless Dir.exist?(output_path)

      ffmpeg_args = [
        "-i", wav_file,
        "-ss", start_time.to_s
      ]

      if end_time
        ffmpeg_args += ["-to", end_time.to_s]
      end

      ffmpeg_args += [
        "-metadata", "title=#{track[:title]}",
        "-metadata", "artist=#{track[:performer]}",
        "-metadata", "genre=#{genre}",
        "-metadata", "album=#{album.name}",
        "-metadata", "year=#{album.year}",
        "-metadata", "track=#{track[:track]}/#{album.total_tracks}",
        "-q:a", "0",
        output_file_path
      ]

      system("ffmpeg", *ffmpeg_args)
      puts "Exported: #{output_file_path}"
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
        duration = stdout.strip.to_f
        return duration
      else
        puts "Error getting duration: #{stderr}"
          return nil
      end
    end
  end
end
