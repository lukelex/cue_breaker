# frozen_string_literal: true

require "spec_helper"

RSpec.describe CueBreaker::Cue::Sheet do
  let(:sheet_file) { cue_sheet_fixture("test") }
  let(:sheet) { described_class.new(sheet_file) }

  before do
    sheet.parse!
  end

  it "stores the sheet string" do
    sheet = described_class.new(sheet_file)

    expect(sheet.cuesheet).to eq(sheet_file)
  end

  describe "#parse!" do
    context "properly formatted sheet" do
      it "returns true if successfully parsed" do
        expect(sheet.parse!).to be_truthy
      end

      it "has the main performer" do
        expect(sheet.performer).to eq("Netsky")
      end

      it "has the main title" do
        expect(sheet.title).to eq("Essential Mix (2010-10-09)")
      end

      it "has the right first track" do
        expect(sheet.songs.first[:title]).to eq("Intro")
      end

      it "has the right last track" do
        expect(sheet.songs.last[:title]).to eq("The Lotus Symphony vs. Uplifting")
      end

      it "has the right first performer" do
        expect(sheet.songs.first[:performer]).to eq("Essential Mix")
      end

      it "has the right last performer" do
        expect(sheet.songs.last[:performer]).to eq("Netsky vs. Genetic Bros")
      end

      it "has the right first index" do
        expect(sheet.songs.first[:index]).to eq([0, 0, 0])
      end

      it "has the right last index" do
        expect(sheet.songs.last[:index]).to eq([115, 22, 47])
      end

      it "has the right first track" do
        expect(sheet.songs.first[:track]).to eq(1)
      end

      it "has the right last track" do
        expect(sheet.songs.last[:track]).to eq(53)
      end

      it "has the right amount of tracks" do
        expect(sheet.songs.size).to eq(53)
      end

      it "has the main file" do
        expect(sheet.file).to eq("2010-10-09 - Essential Mix - Netsky.mp3")
      end

      it "has no tracks files" do
        sheet.songs.each { |song| expect(song[:file]).to be_nil }
      end

      describe "#calculate_song_duration!" do
        it "properly calculates song duration at the beginning of the track" do
          expect(sheet.songs.first[:duration].to_a).to eq([1, 50, 0o7])
        end

        it "properly calculates song duration in the middle of the track" do
          expect(sheet.songs[20][:duration].to_a).to eq([2, 13, 3])
        end

        it "properly calculates song duration of the last song given the user inputs the total track length" do
          sheet = described_class.new(cue_sheet_fixture("test"), 7185)
          sheet.parse!
          expect(sheet.songs.last[:duration].to_a).to eq([4, 22, 28])
        end
      end
    end

    context "improperly formatted sheet" do
      it "should raise an exception for a bogus formatted sheet" do
        sheet = described_class.new("Something bogus")
        expect { sheet.parse! }.to raise_error(described_class::MalformedError)
      end

      it "raises an exception if all our fields don't find the same amount of items" do
        cue = cue_sheet_fixture("malformed")
        sheet = described_class.new(cue)
        expect { sheet.parse! }.to raise_error(described_class::MalformedError)
      end
    end

    context "multiple files sheet" do
      let(:sheet_file) { cue_sheet_fixture("multi_file") }
      let(:sheet) { described_class.new(sheet_file) }

      before do
        sheet.parse!
      end

      it "has the main file" do
        expect(sheet.file).to be_nil
      end

      it "has the right first track file" do
        expect(sheet.songs.first[:file]).to eq("01 - Amerigo.wav")
      end

      it "has the right last track file" do
        expect(sheet.songs.last[:file]).to eq("12 - After The Gold Rush.wav")
      end

      it "has genre" do
        expect(sheet.genre).to eq("Rock")
      end

      it "has date" do
        expect(sheet.date).to eq(2012)
      end
    end
  end

  describe "#position" do
    it "returns the current song in the sheet based on the designated position" do
      expect(sheet.position(1943)).to eq(sheet.songs[14])
    end

    it "returns the first song if a negative position is passed" do
      expect(sheet.position(-5)).to eq(sheet.songs[0])
    end

    it "returns the last song if a position greater than the last index is passed" do
      expect(sheet.position(10_000_000)).to eq(sheet.songs.last)
    end
  end
end
