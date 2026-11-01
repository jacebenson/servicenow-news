require "test_helper"
require "minitest/mock"

class ExtractVideoParticipantsJobTest < ActiveJob::TestCase
  self.fixture_table_names = []

  test "transcript downloads pass the URL as a literal argument after the option terminator" do
    url = "https://example.com/video;$(touch should-not-exist)"
    calls = []
    capture = lambda do |*args|
      calls << args
      [ "no subtitles", nil ]
    end

    Open3.stub(:capture2e, capture) do
      result = ExtractVideoParticipantsJob.new.send(:get_transcript, url)
      assert_equal "No subtitles available", result[:error]
    end

    assert_equal 2, calls.length
    assert_includes calls.first, "--write-auto-sub"
    assert_includes calls.last, "--write-sub"
    calls.each do |args|
      assert_equal "yt-dlp", args.first
      assert_equal [ "--", url ], args.last(2)
    end
  end
end
