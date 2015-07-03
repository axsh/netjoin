require "./lib/ducttape.rb"
require "test/unit"

class TestDucttape < Test::Unit::TestCase

  def test_sample
    assert_equal(4, 2+2)
  end

end
