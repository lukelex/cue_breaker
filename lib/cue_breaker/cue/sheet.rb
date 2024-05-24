# frozen_string_literal: true

require "cue_breaker/cue/index"

module CueBreaker
  module Cue
    class Sheet
      attr_reader :cuesheet, :songs, :track_duration, :performer, :title, :file, :genre, :date

      class MalformedError < ::RuntimeError; end

      PATTERNS = {
        track: /TRACK (\d{1,3}) AUDIO/,
        performer: /PERFORMER "(.*)"/,
        title: /TITLE "(.*)"/,
        index: /INDEX \d{1,3} (\d{1,3}):(\d{1,2}):(\d{1,2})/,
        file: /FILE "(.*)"/,
        genre: /REM GENRE (.*)\b/,
        date: /REM DATE (\d*)/
      }.freeze

      def initialize(cuesheet, track_duration = nil)
        @cuesheet = cuesheet
        @track_duration = Index.new(track_duration) if track_duration
      end

      def parse!
        @songs = parse_titles.map { |title| { title: title } }
        @songs.each_with_index do |song, i|
          song[:performer] = parse_performers[i] || @performer
          song[:track] = parse_tracks[i]
          song[:index] = parse_indices[i]
          song[:file] = parse_files[i]
        end
        parse_genre
        parse_date
        raise MalformedError, "Field amounts are not all present. Cuesheet is malformed!" unless valid?

        calculate_song_durations!
        true
      end

      def position(value)
        index = Index.new(value)

        return @songs.first if index < @songs.first[:index]

        @songs.each_with_index do |song, i|
          return song if song == @songs.last
          return song if between(song[:index], @songs[i + 1][:index], index)
        end
      end

      def valid?
        @songs.all? do |song|
          %i[performer track index title].all? do |key|
            !song[key].nil?
          end
        end
      end

      private

      def calculate_song_durations!
        @songs.each_with_index do |song, i|
          if song == @songs.last
            song[:duration] = (@track_duration - song[:index]) if @track_duration
            return nil
          end
          song[:duration] = @songs[i + 1][:index] - song[:index]
        end
      end

      def between(a, b, position_index)
        (position_index > a) && (position_index < b)
      end

      def parse_titles
        unless @titles
          @titles = cuesheet_scan(:title).map(&:first)
          @title = @titles.delete_at(0)
        end
        @titles
      end

      def parse_performers
        unless @performers
          @performers = cuesheet_scan(:performer).map(&:first)
          @performer = @performers.delete_at(0)
        end
        @performers
      end

      def parse_tracks
        @parse_tracks ||= cuesheet_scan(:track).map { |track| track.first.to_i }
      end

      def parse_indices
        @parse_indices ||= cuesheet_scan(:index).map do |index|
          Index.new([index[0].to_i, index[1].to_i, index[2].to_i])
        end
      end

      def parse_files
        unless @files
          @files = cuesheet_scan(:file).map(&:first)
          @file = @files.delete_at(0) if @files.size == 1
        end
        @files
      end

      def parse_genre
        @cuesheet.scan(PATTERNS[:genre]) do |genre|
          @genre = genre.first
          break
        end
      end

      def parse_date
        @cuesheet.scan(PATTERNS[:date]) do |date|
          @date = date.first.to_i
          break
        end
      end

      def cuesheet_scan(field)
        scan = @cuesheet.scan(PATTERNS[field])
        raise MalformedError, "No fields were found for #{field}" if scan.empty?

        scan
      end
    end
  end
end
