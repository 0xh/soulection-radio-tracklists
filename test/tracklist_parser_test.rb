require 'minitest/autorun'

require_relative '../parser'

class TestTracklistParser < Minitest::Test
  def setup
    @parser
  end

  def test_parsed_output_for_show_286
    parser = TracklistParser.new('./downloads/Show #286.pdf')
    parsed = parser.parse
    assert_equal(286, parsed[:number])
    assert_equal(41, parsed[:tracks].length)
    assert_equal(Date.parse('2016-11-19'), parsed[:date])
    assert_equal(1, parsed[:sessions].length)
    assert_equal('Joe Kay’s Session', parsed[:tracks].first[:session])
    assert_equal('Joe Kay’s Session', parsed[:tracks].last[:session])
  end

  def test_parsed_output_for_show_285
    parser = TracklistParser.new('./downloads/Show #285.pdf')
    parsed = parser.parse
    assert_equal(285, parsed[:number])
    assert_equal(47, parsed[:tracks].length)
    assert_equal(Date.parse('2016-11-12'), parsed[:date])
    assert_equal(1, parsed[:sessions].length)
    assert_equal('Joe Kay’s Session', parsed[:tracks].first[:session])
    assert_equal('Joe Kay’s Session', parsed[:tracks].last[:session])
  end

  def test_parsed_output_for_show_283
    parser = TracklistParser.new('./downloads/Show #283.pdf')
    parsed = parser.parse
    assert_equal(283, parsed[:number])
    assert_equal(40, parsed[:tracks].length)
    assert_equal(Date.parse('2016-10-29'), parsed[:date])
    assert_equal(2, parsed[:sessions].length)
    assert_equal('Joe Kay’s Session', parsed[:tracks].first[:session])
    assert_equal('Ravyn Lenae Interview + Session', parsed[:tracks].last[:session])
  end

  def test_parsed_output_for_show_282
    parser = TracklistParser.new('./downloads/Show #282.pdf')
    parsed = parser.parse
    assert_equal(282, parsed[:number])
    assert_equal(53, parsed[:tracks].length)
    assert_equal(Date.parse('2016-10-22'), parsed[:date])
    assert_equal(1, parsed[:sessions].length)
    assert_equal('Joe Kay’s Session', parsed[:tracks].first[:session])
    assert_equal('Joe Kay’s Session', parsed[:tracks].last[:session])
  end

  def test_parsed_output_for_show_281
    parser = TracklistParser.new('./downloads/Show #281.pdf')
    parsed = parser.parse
    assert_equal(281, parsed[:number])
    assert_equal(43, parsed[:tracks].length)
    assert_equal(Date.parse('2016-10-15'), parsed[:date])
    assert_equal(2, parsed[:sessions].length)
    assert_equal('Joe Kay’s Session', parsed[:tracks].first[:session])
    assert_equal('starRo’s Session + Interview', parsed[:tracks].last[:session])
  end

  def test_parsed_output_for_show_261
    parser = TracklistParser.new('./downloads/Show #261.pdf')
    parsed = parser.parse
    assert_equal(261, parsed[:number])
    assert_equal(43, parsed[:tracks].length)
    # assert_equal(Date.parse('2015-02-01'), parsed[:date])
    assert_equal(1, parsed[:sessions].length)
    assert_equal('Joe Kay’s Session', parsed[:tracks].first[:session])
    assert_equal('Joe Kay’s Session', parsed[:tracks].last[:session])
  end

  def test_parsed_output_for_show_207
    parser = TracklistParser.new('./downloads/Show #207.pdf')
    parsed = parser.parse
    assert_equal(207, parsed[:number])
    assert_equal(67, parsed[:tracks].length)
    # assert_equal(Date.parse('2015-02-01'), parsed[:date])
    assert_equal(1, parsed[:sessions].length)
    assert_equal('Joe Kay’s Session', parsed[:tracks].first[:session])
    assert_equal('Joe Kay’s Session', parsed[:tracks].last[:session])
  end

  def test_parsed_output_for_show_203
    parser = TracklistParser.new('./downloads/Show #203.pdf')
    parsed = parser.parse
    assert_equal(203, parsed[:number])
    assert_equal(67, parsed[:tracks].length)
    assert_equal(Date.parse('2015-02-01'), parsed[:date])
    assert_equal(4, parsed[:sessions].length)
    assert_equal('Joe Kay’s Session', parsed[:tracks].first[:session])
    assert_equal('Joe Kay’s Session', parsed[:tracks].last[:session])
  end

  def test_parsed_output_for_show_202
    parser = TracklistParser.new('./downloads/Show #202.pdf')
    parsed = parser.parse
    assert_equal(202, parsed[:number])
    assert_equal(85, parsed[:tracks].length)
    assert_equal(Date.parse('2014-01-24'), parsed[:date])
    assert_equal(4, parsed[:sessions].length)
    assert_equal('Joe Kay’s Session', parsed[:tracks].first[:session])
    assert_equal('AbJo’s Set', parsed[:tracks].last[:session])
  end

  def test_parsed_output_for_show_200
    parser = TracklistParser.new('./downloads/Show #200.pdf')
    parsed = parser.parse

    assert_equal(200, parsed[:number])
    assert_equal(87, parsed[:tracks].length)
    assert_equal(Date.parse('2015-01-10'), parsed[:date])
    assert_equal(1, parsed[:sessions].length)
    assert_equal('Joe Kay’s Session', parsed[:tracks].first[:session])
    assert_equal('Joe Kay’s Session', parsed[:tracks].last[:session])
  end
end
