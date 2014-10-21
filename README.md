# SoundcloudStreamer

streams and saves whole playlist and single tracks as mp3 from soundcloud via api.

## Installation

Add this line to your application's Gemfile:

    gem 'soundcloud_streamer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install soundcloud_streamer

## Usage

    $ soundcloud_streamer help

    $ soundcloud_streamer help playlist

### Example

    $ soundcloud_streamer playlist https://soundcloud.com/mathew-steven-klein/sets/her-soundtrack --client-id=07b516960d652769d2a00c9a6a26f27d --target-dir="Her Soundtrack by Arcade Fire"

## Contributing

1. Fork it ( https://github.com/mmichaa/soundcloud_streamer/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
