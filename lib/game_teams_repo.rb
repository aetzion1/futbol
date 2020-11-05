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

  def most_accurate_team(season_id)
    rates =  @game_teams.team_conversion_percent(season_id)
    data_collector = rates.max_by do |team, ratio|
      ratio
    end
    @stat_tracker.team_name(data_collector[0])
  end

  def least_accurate_team(season_id)
    rates = @game_teams.team_conversion_percent(season_id)
    data_collector = rates.min_by do |team, ratio|
      ratio
    end
    @stat_tracker.team_name(data_collector[0])
  end

  def best_offense
    best_team = @game_teams.goals_sum.key(@game_teams.goals_sum.values.max)
    @stat_tracker.team_name(best_team)
  end

  def worst_offense
    worst_team = @game_teams.goals_sum.key(@game_teams.goals_sum.values.min)
    @stat_tracker.team_name(worst_team)
  end

  def highest_scoring_visitor
    best_visit = @game_teams.games_sum("away").key(@game_teams.games_sum("away").values.max)
    @stat_tracker.team_name(best_visit)
  end
  
  def lowest_scoring_visitor
    worst_visit =  @game_teams.games_sum("away").key( @game_teams.games_sum("away").values.min)
    @stat_tracker.team_name(worst_visit)
  end

  def highest_scoring_home_team
    best_home =  @game_teams.games_sum("home").key( @game_teams.games_sum("home").values.max)
    @stat_tracker.team_name(best_home)
  end

  def lowest_scoring_home_team
    worst_home =  @game_teams.games_sum("home").key( @game_teams.games_sum("home").values.min)
    @stat_tracker.team_name(worst_home)
  end
  
  def most_tackles(season_id)
    @stat_tracker.team_name(@game_teams.tackles_for_team(season_id).key(@game_teams.tackles_for_team(season_id).values.max))
  end

  def fewest_tackles(season_id)
    fewest = @game_teams.tackles_for_team(season_id).key(@game_teams.tackles_for_team(season_id).values.min)
    binding.pry
    @stat_tracker.team_name(fewest)
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

  def favorite_opponent(team_id)
    fav = @game_teams.win_rate_calc(team_id).key(@game_teams.win_rate_calc(team_id).values.min)
    @stat_tracker.team_name(fav)
  end

  def rival(team_id)
    rival = @game_teams.win_rate_calc(team_id).key(@game_teams.win_rate_calc(team_id).values.max)
    @stat_tracker.team_name(rival)
  end

end