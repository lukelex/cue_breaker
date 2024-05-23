module CueBreaker
  class FFmpegArgs
    def initialize(file, album, track)
      @file, @album, @track = file, album, track
    end

    def options(output_path)
      [
        file,
        start,
        finish,
        metadata,
        ["-q:a", "0"],
        output_file_path(output_path)
      ].reject(&:empty?).flatten
    end

    def file
      ["-i", @file]
    end

    def start
      ["-ss", @track.start.to_s]
    end

    def finish
      return [] unless @track.finish

      ["-to", @track.finish.to_s]
    end

    def metadata
      [
        "-metadata", "title=#{@track.title}",
        "-metadata", "artist=#{@album.performer}",
        "-metadata", "genre=#{@album.genre}",
        "-metadata", "album=#{@album.title}",
        "-metadata", "date=#{@album.date}",
        "-metadata", "track=#{@album.track_number(@track)}",
      ]
    end

    def output_file_path(output_path)
      File.join(
        output_path,
        "#{format('%02d', @track.number)} - #{@track.title}.mp3"
      )
    end
  end
end
