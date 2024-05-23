# CueBreaker

CueBreaker is a Ruby script that parses CUE files and converts
associated WAV files into respective MP3 track files. It uses the 
`rubycue` gem for parsing and FFmpeg for audio conversion and 
metadata handling.

## Features

- Parses CUE files to extract track information.
- Converts WAV segments to MP3 files.
- Adds metadata to the MP3 files (e.g. title, artist).

## Requirements

- Ruby
- FFmpeg

## Installation

1. **Install Ruby:** Download and install Ruby from [ruby-lang.org](https://www.ruby-lang.org/).
2. **Install FFmpeg:** Download and install FFmpeg from [ffmpeg.org](https://ffmpeg.org/download.html) and ensure it is added to your system's PATH.

```sh
$ gem install cue_breaker
```

## Usage

Here's an example of how to use CueBreaker:

```sh
$ cue_break --cue rockband.cue --wav rockband.wav --output $HOME/music/rockband
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [rubycue](https://github.com/blakesmith/rubycue) for CUE file parsing.
- [FFmpeg](https://ffmpeg.org/) for audio processing.
