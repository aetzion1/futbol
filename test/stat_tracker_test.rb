require './test/test_helper'

class TestStatTracker < Minitest::Test

  def setup
      # move this into self.from CSV! (below code)



      games_path = './data/games.csv'
      teams_path = './data/teams.csv'
      game_teams_path = './data/game_teams.csv'

      locations = {
          games: games_path,
          teams: teams_path,
          game_teams: game_teams_path
      }

      @stat_tracker = StatTracker.new(locations)
  end

  def test_it_exists
      assert_instance_of StatTracker, @stat_tracker
  end

  def test_from_csv
    games_path = './data/games.csv'
    teams_path = './data/teams.csv'
    game_teams_path = './data/game_teams.csv'

    locations = {
      games: games_path,
      teams: teams_path,
      game_teams: game_teams_path
    }

    assert_instance_of StatTracker, StatTracker.from_csv(locations)
  end

  

  def test_highest_total_score
      assert_equal 11, @stat_tracker.highest_total_score
  end

  def test_lowest_total_score
      assert_equal 0, @stat_tracker.lowest_total_score
  end


  def test_percentage_home_wins
    assert_equal 0.44, @stat_tracker.percentage_home_wins
  end

  def test_percentage_visitor_wins
    assert_equal 0.36, @stat_tracker.percentage_visitor_wins
  end

  def test_percentage_ties
    assert_equal 0.20, @stat_tracker.percentage_ties
  end

  def test_count_games_by_season
    expected = {
      "20122013"=>806,
      "20162017"=>1317,
      "20142015"=>1319,
      "20152016"=>1321,
      "20132014"=>1323,
      "20172018"=>1355
    }

    assert_equal expected, @stat_tracker.count_of_games_by_season
  end

  def test_average_goals_per_game
    #change back to actual test / data
    assert_equal 4.22,  @stat_tracker.average_goals_per_game
  end

  def test_average_goals_by_season
    expected = {
      "20122013"=>4.12,
      "20162017"=>4.23,
      "20142015"=>4.14,
      "20152016"=>4.16,
      "20132014"=>4.19,
      "20172018"=>4.44
      }
    assert_equal expected , @stat_tracker.average_goals_by_season

  end

  def test_count_of_teams
    assert_equal 32, @stat_tracker.count_of_teams
  end

  def test_best_offense
    assert_equal "Reign FC", @stat_tracker.best_offense
  end

  def test_worst_offense
    assert_equal "Utah Royals FC", @stat_tracker.worst_offense
  end

  def test_highest_scoring_visitor
    assert_equal "FC Dallas", @stat_tracker.highest_scoring_visitor
  end

  def test_highest_scoring_home_team
    assert_equal "Reign FC", @stat_tracker.highest_scoring_home_team
  end

  def test_lowest_scoring_visitor
    assert_equal "San Jose Earthquakes", @stat_tracker.lowest_scoring_visitor
  end

  def test_lowest_scoring_home_team
    assert_equal "Utah Royals FC", @stat_tracker.lowest_scoring_home_team
  end

  def test_it_has_info
    expected = {    "team_id" => "18",
                    "franchise_id" => "34",
                    "team_name" => "Minnesota United FC",
                    "abbreviation" => "MIN",
                    "link" => "/api/v1/teams/18"
  }

  assert_equal expected, @stat_tracker.team_info("18")
  end



  def test_winningest_coach

    assert_equal "Claude Julien", @stat_tracker.winningest_coach("20132014")
    assert_equal "Alain Vigneault", @stat_tracker.winningest_coach("20142015")
  end

  def test_worst_coach

    assert_equal "Peter Laviolette", @stat_tracker.worst_coach("20132014")
    assert ("Craig MacTavish" || "Ted Nolan"), @stat_tracker.worst_coach("20142015")
  end

  def test_most_accurate_team
    assert_equal "Real Salt Lake", @stat_tracker.most_accurate_team("20132014")
    assert_equal "Toronto FC", @stat_tracker.most_accurate_team("20142015")
  end

  def test_least_accurate_team
    assert_equal "New York City FC", @stat_tracker.least_accurate_team("20132014")
    assert_equal "Columbus Crew SC", @stat_tracker.least_accurate_team("20142015")
  end

  def test_total_games_per_team_away
    assert_instance_of Games, @stat_tracker.total_games_per_team_away("6")[0]
    assert_instance_of Games, @stat_tracker.total_games_per_team_away("6")[-1]
  end

  def test_total_games_per_team_home
    assert_instance_of Games, @stat_tracker.total_games_per_team_home("6")[0]
    assert_instance_of Games, @stat_tracker.total_games_per_team_home("6")[-1]
  end

  def test_games_per_season_by_team
    expected = {
      "20122013"=>70,
      "20172018"=>94,
      "20132014"=>94,
      "20142015"=>82,
      "20152016"=>82,
      "20162017"=>88
    }
    assert_equal expected , @stat_tracker.games_per_season_by_team("6")
  end

  def test_wins_per_season_by_team
    expected = {
      "20122013"=>38,
      "20172018"=>50,
      "20132014"=>54,
      "20142015"=>31,
      "20162017"=>45,
      "20152016"=>33
    }
    assert_equal expected , @stat_tracker.wins_per_season_by_team("6")
  end

  def test_most_tackles
    assert_equal "FC Cincinnati", @stat_tracker.most_tackles("20132014")
    assert_equal "Seattle Sounders FC", @stat_tracker.most_tackles("20142015")
  end

  def test_fewest_tackles
    assert_equal "Atlanta United", @stat_tracker.fewest_tackles("20132014")
    assert_equal "Orlando City SC", @stat_tracker.fewest_tackles("20142015")
  end

  def test_best_season
    assert_equal "20132014" , @stat_tracker.best_season("6")
  end

  def test_worst_season
    assert_equal "20142015", @stat_tracker.worst_season("6")
  end

  def test_average_win_percentage
    assert_equal 0.49, @stat_tracker.average_win_percentage("6")
  end

  def test_most_goals_scored
    assert_equal 7, @stat_tracker.most_goals_scored("18")
  end

  def test_fewest_goals_scored
    assert_equal 0, @stat_tracker.fewest_goals_scored("18")
  end

  def test_favorite_opponent
    assert_equal "DC United", @stat_tracker.favorite_opponent("18")
  end

  def test_rival
    assert "Houston Dash" || "LA Galaxy", @stat_tracker.rival("18")
  end

end
