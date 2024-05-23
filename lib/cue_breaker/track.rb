require 'delegate'

module CueBreaker
  class Track
    attr_reader :title, :number, :start, :finish

    def initialize(title:, number:, start:, finish:)
      @title, @number, @start, @finish = title, number, start, finish
    end

    def present
      @_present ||= Presenter.new(self)
    end

    class Presenter < SimpleDelegator
      def start
        parse_time(super)
      end

      def finish
        super ? parse_time(super) : nil
      end

      private

      def parse_time(time_str)
        parts = time_str.split(':').map(&:to_f)
        (parts[0] * 60) + parts[1] + (parts[2] / 75.0)
      end
    end
  end
end
