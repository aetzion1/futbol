require './test/test_helper'
require './lib/game'

class GameTest < Minitest::Test

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

    #@game = Game.new(@row)
  end

  def test_it_exists
    game = Game.new(@row)
    assert_instance_of Game, game
  end

  def test_it_calculates_winner
    home_team = mock("Home Team Game")
    home_team.expects(:home_goals).returns(3)
    home_team.expects(:away_goals).returns(2)
    # away_team = mock("Away Team Game")
    # away_team.expected(:away_goals).returns(2)

    assert_equal :home, home_team.calculate_winner

  end

end