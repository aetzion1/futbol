require './test/test_helper'

class GamesTest < Minitest::Test

  def setup
    @row = Hash.new
    @row[:game_id] = "2012030221"
    @row[:season] = "20122013"
    @row[:type] = "Postseason"
    @row[:date_time] = "5/16/13"
    @row[:away_team_id] = 3
    @row[:home_team_id] = 6
    @row[:away_goals]  = 2
    @row[:home_goals]  = 3
    @row[:venue] =  "Toyota Stadium"
    @row[:venue_link] = "/api/v1/venues/null"

    @game = Games.new(@row)
  end

  def test_it_exists
    game = Games.new(@row)
    assert_instance_of Games, game
  end

  def test_it_has_attributes
    assert_equal "2012030221", @game.game_id
    assert_equal  "20122013", @game.season
    assert_equal "Postseason", @game.type
    assert_equal "5/16/13", @game.date_time
    assert_equal 3, @game.away_team_id
    assert_equal 6, @game.home_team_id
    assert_equal 2, @game.away_goals
    assert_equal 3, @game.home_goals
    assert_equal "Toyota Stadium", @game.venue
    assert_equal "/api/v1/venues/null", @game.venue_link
  end

  def test_it_calculates_winner
    assert_equal :home, @game.calculate_winner

    @game.stubs(:away_goals).returns(3)
    @game.stubs(:home_goals).returns(2)
    
    assert_equal :away, @game.calculate_winner
  end
end