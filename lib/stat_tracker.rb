require 'CSV'
require_relative './game'
require_relative './teams'
require_relative './game_teams'

class StatTracker

  def initialize(locations)
    @games_path = locations[:games]
    @teams_path = locations[:teams]
    @game_teams_path = locations[:game_teams]
    @games_repo = GameRepo.new(@games_path)
    @game_teams_repo = GameTeamsRepo.new(@game_teams_path, self)
    @teams_repo = TeamsRepo.new(@teams_path)
  end

  def self.from_csv(locations)
    StatTracker.new(locations)
  end

  def highest_total_score
    @games_repo.highest_total_score
  end

  def lowest_total_score
    @games_repo.lowest_total_score
  end

  def percentage_home_wins
    @games_repo.percentage_home_wins
  end

  def percentage_visitor_wins
    @games_repo.percentage_visitor_wins
  end

  def percentage_ties
    @games_repo.percentage_ties
  end

  def count_of_games_by_season
    @games_repo.count_of_games_by_season
  end

  def average_goals_per_game
    @games_repo.average_goals_per_game
  end

  def average_goals_by_season
    @games_repo.average_goals_by_season
  end

  def count_of_teams
    @games_repo.count_of_teams
  end

  def best_offense
    @game_teams_repo.best_offense
  end

  def worst_offense
    @game_teams_repo.worst_offense
  end

  def highest_scoring_visitor
    @game_teams_repo.highest_scoring_visitor
  end

  def highest_scoring_home_team
    @game_teams_repo.highest_scoring_home_team
  end

  def lowest_scoring_visitor
    @game_teams_repo.lowest_scoring_visitor
  end

  def lowest_scoring_home_team
    @game_teams_repo.lowest_scoring_home_team
  end

  def winningest_coach(season_id)
    @game_teams_repo.winningest_coach(season_id)
  end

  def worst_coach(season_id)
    @game_teams_repo.worst_coach(season_id)
  end

  #MOST AND LEAST ACCURATE - DISCUSS WITH TEAM
  def most_accurate_team(season_id)
    @game_teams_repo.most_accurate_team(season_id)
  end

  def least_accurate_team(season_id)
    @game_teams_repo.least_accurate_team(season_id)
  end

  def most_tackles(season_id)
    @game_teams_repo.most_tackles(season_id)
  end

  def fewest_tackles(season_id)
    @game_teams_repo.fewest_tackles(season_id)
  end

  def team_info(arg_id)
    @teams_repo.team_info(arg_id)
  end
  ### DISCUSS BEST/WORST SEASON WITH TEAM. CAN WE USE BEST/WORST COACH AND RUN BY TEAM?
  def best_season(team_id)
    @games_repo.best_season(team_id)
  end

  def worst_season(team_id)
    @games_repo.worst_season(team_id)
  end

  # discuss with team. should we havce this many / any helper methods?

  def average_win_percentage(team_id)
    wins = 0
    total_game_count = total_games_per_team_away(team_id).count + total_games_per_team_home(team_id).count

    total_games_per_team_home(team_id).each do |game|
      if game.calculate_winner == :home
        wins += 1
      end
    end

    total_games_per_team_away(team_id).each do |game|
      if game.calculate_winner == :away
        wins += 1
      end
    end
    (wins.to_f / total_game_count).round(2)
  end

  def most_goals_scored(team_id)
    goals = 0
    team_set = @game_teams_repo.game_teams_by_team
    
    team_set.each do |team, games|
      if team_id == team
        goals = games.max_by do |game|
          game.goals
        end.goals
      end
    end

    goals
  end

  def fewest_goals_scored(team_id)
    goals = 0
    team_set = @game_teams_repo.game_teams_by_team

    team_set.each do |team, games|
      if team_id == team
        goals = games.min_by do |game|
          game.goals
        end.goals
      end
    end

    goals
  end

  def favorite_opponent(team_id)
    game_set = @game_teams_repo.game_teams_by_team_id[team_id]
    team_set = @game_teams_repo.game_teams_by_team
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
    fav = win_rate.key(win_rate.values.min)
    @teams_repo.all_teams.find do |team|
      team.team_id == fav
    end.teamname
  end

  def rival(team_id)
    game_set = @game_teams_repo.game_teams_by_team_id[team_id]
    team_set = @game_teams_repo.game_teams_by_team
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

    fav = win_rate.key(win_rate.values.max)
    @teams_repo.all_teams.find do |team|
      team.team_id == fav
    end.teamname
  end


  #### HELPER METHODS TO DISCUSS ######
  def season_game_ids
    @games_repo.season_game_ids
  end
  
  def team_name(id)
    @teams_repo.team_name(id)
  end

  def game_ids_by_season(season_id)
    @games_repo.game_ids_by_season(season_id)
  end

  def game_team_by_season(season_id)
    @game_teams_repo.game_team_by_season(season_id)
  end

  def games_by_team_id(season_id)
    @game_teams_repo.games_by_team_id(season_id)
  end

  def team_conversion_percent(season_id)
   @game_teams_repo.team_conversion_percent(season_id)
  end
  
  def total_games_per_team_away(team_id)
    @games_repo.total_games_per_team_away(team_id)
  end

  def total_games_per_team_home(team_id)
    @games_repo.total_games_per_team_home(team_id)
  end

  def games_per_season_by_team(team_id)

    games_by_season = Hash.new(0)
    total_games_per_team = total_games_per_team_away(team_id) + total_games_per_team_home(team_id)

    total_games_per_team.each do |game|
      games_by_season[game.season] += 1
    end
    games_by_season
  end

  def wins_per_season_by_team(team_id)
    @games_repo.wins_per_season_by_team(team_id)
  end

end