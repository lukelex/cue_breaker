# frozen_string_literal: true

require "delegate"

module CueBreaker
  class Album
    attr_reader :title, :performer, :genre, :total_tracks, :date

    def initialize(title:, performer:, genre:, total_tracks:, date:)
      @title = title
      @performer = performer
      @genre = genre
      @total_tracks = total_tracks
      @date = date
    end

    def present
      @_present ||= Presenter.new(self)
    end

    class Presenter < SimpleDelegator
      def track_number(track)
        "#{track.number}/#{total_tracks}"
      end

      def genre
        super&.gsub(%r{[<>:"/\\|?*]}, "").to_s
      end
    end
  end
end
