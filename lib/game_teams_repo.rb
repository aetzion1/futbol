require_relative './game_teams'
require_relative './game_teams_repo_helper'

class GameTeamsRepo

  def initialize(game_teams_path, stat_tracker)
    @game_teams = GameTeamsRepoHelper.new(game_teams_path, self)
    @stat_tracker = stat_tracker
  end
  
  def season_game_ids
    @stat_tracker.season_game_ids
  end

  def winningest_coach(season_id)
    game_set = @stat_tracker.game_ids_by_season(season_id)
    game_teams_set = @game_teams.game_teams_by_coach
    @game_teams.win_rate(game_set, game_teams_set).key(@game_teams.win_rate(game_set, game_teams_set).values.reject{|x| x.nan?}.max)
  end

  def worst_coach(season_id)
    game_set = @stat_tracker.game_ids_by_season(season_id)
    game_teams_set = @game_teams.game_teams_by_coach
    @game_teams.win_rate(game_set, game_teams_set).key(@game_teams.win_rate(game_set, game_teams_set).values.reject{|x| x.nan?}.min)
  end

  
  def team_conversion_percent(season_id)
    team_ratio = {}
    season_id_games = @game_teams.games_by_team_id(season_id)

    season_id_games.map do |team, games|
      goals = 0.0
      shots = 0.0
      games.map do |game|
        goals += game.goals
        shots += game.shots
      end
      team_ratio[team] = goals / shots
    end

    team_ratio
  end

  def most_accurate_team(season_id)
    rates = team_conversion_percent(season_id)

    data_collector = rates.max_by do |team, ratio|
      ratio
    end

    @stat_tracker.team_name(data_collector[0])
  end

  def least_accurate_team(season_id)
    rates = team_conversion_percent(season_id)

    data_collector = rates.min_by do |team, ratio|
      ratio
    end

    @stat_tracker.team_name(data_collector[0])
  end

  def goals_sum
    test = @game_teams.game_teams_by_team
    average_goals = {}
    test.map do |team , games|
      average_goals[team] = (games.sum {|game|  game.goals}).to_f / games.count
    end
    average_goals
  end

  def best_offense
    best_team = goals_sum.key(goals_sum.values.max)
    @stat_tracker.team_name(best_team)
  end

  def worst_offense
    best_team = goals_sum.key(goals_sum.values.min)
    @stat_tracker.team_name(best_team)
  end

  def games_sum(hoa_state)
    test = @game_teams.game_teams_by_hoa(hoa_state)
    average_goals = {}

    test.map do |team , games|
      average_goals[team] = (games.sum {|game|  game.goals}).to_f / games.count
    end 
    average_goals
  end

  def highest_scoring_visitor
    best_visit = games_sum("away").key(games_sum("away").values.max)
    @stat_tracker.team_name(best_visit)
  end

  def highest_scoring_home_team
    best_home = games_sum("home").key(games_sum("home").values.max)
    @stat_tracker.team_name(best_home)
  end

  def lowest_scoring_visitor
    best_visit = games_sum("away").key(games_sum("away").values.min)
    @stat_tracker.team_name(best_visit)
  end

  def lowest_scoring_home_team
    worst_home = games_sum("home").key(games_sum("home").values.min)
    @stat_tracker.team_name(worst_home)
  end

  def tackles_for_team(season_id)
    team_tackles = {}
    
    test = @game_teams.games_by_team_id(season_id)
    test.map do |team, games|
      tackles = 0
      games.map do |game|
        tackles += game.tackles
      end
      team_tackles[team] = tackles
    end
    team_tackles
  end

  def most_tackles(season_id)
    @stat_tracker.team_name(tackles_for_team(season_id).key(tackles_for_team(season_id).values.max))
  end

  def fewest_tackles(season_id)
    @stat_tracker.team_name(tackles_for_team(season_id).key(tackles_for_team(season_id).values.min))
  end

  def most_goals_scored(team_id)
    team_set = @game_teams.games_teams_by_team_id(team_id)

    team_set.max_by do |games|
      games.goals
    end.goals
  end

  def fewest_goals_scored(team_id)
   
    team_set = @game_teams.games_teams_by_team_id(team_id)

    team_set.min_by do |games|
      games.goals
    end.goals

  end

  def win_rate_calc(team_id)
    game_set = @game_teams.game_teams_by_team_id[team_id]
    team_set = @game_teams.game_teams_by_team
    win_rate = {}

    team_set.map do |team, games|
      games_won = 0.0
      games_total = 0.0
      games.map do |game|
        games_won += 1 if game.result == "WIN" && game_set.include?(game.game_id)
        games_total += 1 if game_set.include?(game.game_id)
      end
      win_rate[team] = games_won / games_total
    end
    win_rate
  end

  def favorite_opponent(team_id)
    fav = win_rate_calc(team_id).key(win_rate_calc(team_id).values.min)
    @stat_tracker.team_name(fav)
  end

  def rival(team_id)
    rival = win_rate_calc(team_id).key(win_rate_calc(team_id).values.max)
    @stat_tracker.team_name(rival)
  end

end