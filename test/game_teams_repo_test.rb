require './test/test_helper'

class GameTeamsRepoTest < Minitest::Test
  def setup
    games_path = './data/games.csv'
    teams_path = './data/teams.csv'
    game_teams_path = './data/game_teams.csv'

    locations = {
        games: games_path,
        teams: teams_path,
        game_teams: game_teams_path
    }

    @stat_tracker = StatTracker.new(locations)
    @game_teams_path = './data/game_teams.csv'
    @game_teams_repo_test = GameTeamsRepo.new(@game_teams_path, @stat_tracker)
    @teams_path = './data/teams.csv'
    @teams = TeamsRepo.new(@teams_path)
  end

  def test_make_game_teams
    assert_instance_of GameTeams, @game_teams_repo_test.make_game_teams(@game_teams_path)[0]
    assert_instance_of GameTeams, @game_teams_repo_test.make_game_teams(@game_teams_path)[-1]
  end

  def test_best_offense
    assert_equal "Reign FC", @game_teams_repo_test.best_offense
  end

  def test_worst_offense
    assert_equal  "Utah Royals FC", @game_teams_repo_test.worst_offense
  end

  def test_highest_scoring_visitor
    assert_equal "FC Dallas", @game_teams_repo_test.highest_scoring_visitor
  end

  def test_highest_scoring_home_team
    assert_equal "Reign FC", @game_teams_repo_test.highest_scoring_home_team
  end

  def test_lowest_scoring_visitor
    assert_equal "San Jose Earthquakes" , @game_teams_repo_test.lowest_scoring_visitor
  end

  def test_lowest_scoring_home
    assert_equal "Utah Royals FC", @game_teams_repo_test.lowest_scoring_home_team
  end

  def test_conversion_percent
    assert_equal "3", @game_teams_repo_test.team_conversion_percent("20122013").keys.first
    assert_equal 0.25396825396825395, @game_teams_repo_test.team_conversion_percent("20122013").values.first
  end

end  
