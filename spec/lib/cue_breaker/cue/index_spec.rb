# frozen_string_literal: true

require "spec_helper"

RSpec.describe CueBreaker::Cue::Index do
  describe "init" do
    it "allows empty initialization" do
      expect { described_class.new }.not_to raise_error
    end

    it "initializes from an array if specified default" do
      index = described_class.new([5, 0, 75])
      expect(index.minutes).to eql(5)
      expect(index.seconds).to eql(0)
      expect(index.frames).to eql(75)
    end

    it "initializes from integer seconds less than a minute" do
      index = described_class.new(30)
      expect(index.minutes).to eql(0)
      expect(index.seconds).to eql(30)
      expect(index.frames).to eql(0)
    end

    it "initializes from integer seconds over a minute" do
      index = described_class.new(90)
      expect(index.minutes).to eql(1)
      expect(index.seconds).to eql(30)
      expect(index.frames).to eql(0)
    end

    it "initializes from integer seconds at a minute" do
      index = described_class.new(60)
      expect(index.minutes).to eql(1)
      expect(index.seconds).to eql(0)
      expect(index.frames).to eql(0)
    end

    it "raises an error if the array size is not size 3" do
      expect { described_class.new([0, 0, 0, 0]) }.to raise_error(ArgumentError)
    end

    it "raises an error if not all the array elements are integers" do
      expect { described_class.new([0, "moose", 0]) }.to raise_error(ArgumentError)
    end

    context "conversions" do
      describe "#to_f" do
        it "converts an array value under a minute" do
          index = described_class.new([0, 30, 0])
          expect(index.to_f).to eql(30.0)
        end

        it "converts an array value over a minute" do
          index = described_class.new([1, 30, 0])
          expect(index.to_f).to eql(90.0)
        end

        it "converts an array value over a minute with frames" do
          index = described_class.new([1, 30, 74])
          expect(index.to_f).to eql(90 + (74 / 75.0))
        end
      end

      describe "#to_s" do
        it "renders the index as a string with leading zeroes" do
          expect(described_class.new([1, 30, 74]).to_s).to eql("01:30:74")
        end
      end

      describe "#to_i" do
        it "converts to seconds and rounds down" do
          index = described_class.new([0, 30, 74])
          expect(index.to_i).to eql(30)
        end
      end

      describe "#to_a" do
        it "converts to an array" do
          index = described_class.new([1, 2, 3])
          expect(index.to_a).to eql([1, 2, 3])
        end
      end
    end

    context "computations" do
      describe "#+" do
        it "returns an object of Class Index" do
          index1 = described_class.new([0, 30, 0])
          index2 = described_class.new([0, 30, 0])

          expect((index1 + index2).class).to eql(described_class)
        end

        it "adds two indices under a minute" do
          index1 = described_class.new([0, 30, 0])
          index2 = described_class.new([0, 30, 0])

          expect((index1 + index2).to_a).to eql([1, 0, 0])
        end

        it "adds two indices over a minute" do
          index1 = described_class.new([1, 30, 0])
          index2 = described_class.new([2, 20, 0])

          expect((index1 + index2).to_a).to eql([3, 50, 0])
        end

        it "adds two indices with frames" do
          index1 = described_class.new([1, 30, 50])
          index2 = described_class.new([2, 20, 50])

          expect((index1 + index2).to_a).to eql([3, 51, 25])
        end

        it "adds two indices with only frames" do
          index1 = described_class.new([0, 0, 50])
          index2 = described_class.new([0, 0, 25])

          expect((index1 + index2).to_a).to eql([0, 1, 0])
        end
      end

      describe "#-" do
        it "returns an object of Class Index" do
          index1 = described_class.new([0, 30, 0])
          index2 = described_class.new([0, 30, 0])

          expect((index1 - index2).class).to eql(CueBreaker::Cue::Index)
        end

        it "subtracts two indices with only frames" do
          index1 = described_class.new([0, 0, 50])
          index2 = described_class.new([0, 0, 25])

          expect((index1 - index2).to_a).to eql([0, 0, 25])
        end

        it "subtracts two indices with minutes" do
          index1 = described_class.new([3, 20, 50])
          index2 = described_class.new([2, 40, 25])

          expect((index1 - index2).to_a).to eql([0, 40, 25])
        end

        it "subtracts two indices with even minutes" do
          index1 = described_class.new([3, 0, 0])
          index2 = described_class.new([2, 0, 0])

          expect((index1 - index2).to_a).to eql([1, 0, 0])
        end
      end

      describe "#>" do
        it "returns true for frames" do
          index1 = described_class.new([0, 0, 50])
          index2 = described_class.new([0, 0, 25])

          expect(index1 > index2).to be_truthy
        end

        it "returns true for seconds" do
          index1 = described_class.new([0, 30, 50])
          index2 = described_class.new([0, 29, 25])

          expect(index1 > index2).to be_truthy
        end

        it "returns true for minutes" do
          index1 = described_class.new([2, 30, 50])
          index2 = described_class.new([1, 29, 25])

          expect(index1 > index2).to be_truthy
        end

        it "returns false for the same time" do
          index1 = described_class.new([1, 30, 50])
          index2 = described_class.new([1, 30, 50])

          expect(index1 > index2).to be_falsey
        end
      end

      describe "#<" do
        it "returns false for frames" do
          index1 = described_class.new([0, 0, 50])
          index2 = described_class.new([0, 0, 25])

          expect(index1 < index2).to be_falsey
        end

        it "returns false for seconds" do
          index1 = described_class.new([0, 30, 50])
          index2 = described_class.new([0, 29, 25])

          expect(index1 < index2).to be_falsey
        end

        it "returns false for minutes" do
          index1 = described_class.new([2, 30, 50])
          index2 = described_class.new([1, 29, 25])

          expect(index1 < index2).to be_falsey
        end

        it "returns false for the same time" do
          index1 = described_class.new([1, 30, 50])
          index2 = described_class.new([1, 30, 50])

          expect(index1 < index2).to be_falsey
        end
      end

      describe "#==" do
        it "returns true if they're the same" do
          index1 = described_class.new([1, 30, 50])
          index2 = described_class.new([1, 30, 50])

          expect(index1 == index2).to be_truthy
        end

        it "returns false if they're not the same" do
          index1 = described_class.new([1, 30, 50])
          index2 = described_class.new([1, 30, 51])

          expect(index1 == index2).to be_falsey
        end
      end
    end
  end
end
