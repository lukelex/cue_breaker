require 'delegate'

module CueBreaker
  class Album
    attr_reader :title, :performer, :genre, :total_tracks, :date

    def initialize(title:, performer:, genre:, total_tracks:, date:)
      @title, @performer, @genre, @total_tracks, @date = title, performer, genre, total_tracks, date
    end

    def present
      @_present ||= Presenter.new(self)
    end

    class Presenter < SimpleDelegator
      def track_number(track)
        "#{track.number}/#{total_tracks}"
      end

      def genre
        super.gsub(/[<>:"\/\\|?*]/, '')
      end
    end
  end
end