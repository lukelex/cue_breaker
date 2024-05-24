# frozen_string_literal: true

module CueBreaker
  module Cue
    class Index
      include Enumerable

      SECONDS_PER_MINUTE = 60
      FRAMES_PER_SECOND = 75
      FRAMES_PER_MINUTE = FRAMES_PER_SECOND * 60

      attr_reader :minutes, :seconds, :frames

      class << self
        def parse_from(value)
          case value
          when Array
            from_list(value)
          when Integer
            from_integer(value)
          end
        end

        private

        def from_list(array)
          if array.size != 3 || array.any? { |element| !element.is_a?(Integer) }
            raise ArgumentError,
                  "Must be initialized with an array in the format of [minutes, seconds,frames], all integers"
          end

          array
        end

        def from_integer(seconds)
          minutes = 0
          frames = 0

          while seconds >= SECONDS_PER_MINUTE
            minutes += 1
            seconds -= SECONDS_PER_MINUTE
          end

          [minutes, seconds, frames]
        end
      end

      def initialize(value = nil)
        @minutes, @seconds, @frames = *self.class.parse_from(value)
      end

      def to_f
        ((@minutes * SECONDS_PER_MINUTE) + @seconds + (@frames.to_f / FRAMES_PER_SECOND)).to_f
      end

      def to_i
        to_f.floor
      end

      def to_a
        [@minutes, @seconds, @frames]
      end

      def to_s
        "#{format('%02d', @minutes)}:#{format('%02d', @seconds)}:#{format('%02d', @frames)}"
      end

      def +(other)
        self.class.new(carrying_addition(other))
      end

      def -(other)
        self.class.new(carrying_subtraction(other))
      end

      def >(other)
        to_f > other.to_f
      end

      def <(other)
        to_f < other.to_f
      end

      def ==(other)
        to_a == other.to_a
      end

      def each(&block)
        to_a.each(&block)
      end

      private

      def carrying_addition(other)
        minutes = @minutes + other.minutes
        seconds = @seconds + other.seconds
        frames = @frames + other.frames

        seconds, frames = *convert_with_rate(frames, seconds, FRAMES_PER_SECOND)
        minutes, seconds = *convert_with_rate(seconds, minutes, SECONDS_PER_MINUTE)
        [minutes, seconds, frames]
      end

      def carrying_subtraction(other)
        seconds = minutes = 0

        my_frames = @frames + (@seconds * FRAMES_PER_SECOND) + (@minutes * FRAMES_PER_MINUTE)
        other_frames = other.frames + (other.seconds * FRAMES_PER_SECOND) + (other.minutes * FRAMES_PER_MINUTE)
        frames = my_frames - other_frames

        seconds, frames = *convert_with_rate(frames, seconds, FRAMES_PER_SECOND)
        minutes, seconds = *convert_with_rate(seconds, minutes, SECONDS_PER_MINUTE)
        [minutes, seconds, frames]
      end

      def convert_with_rate(from, to, rate, step = 1)
        while from >= rate
          to += step
          from -= rate
        end
        [to, from]
      end
    end
  end
end
