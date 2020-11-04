require_relative './games'

class GamesRepo
  def initialize(games_path)
    @games = make_games(games_path)
  end

  def make_games(games_path)
    games = []
    CSV.foreach(games_path, headers: true, header_converters: :symbol) do |row|
      games << Games.new(row)
    end
    games
  end

  def total_games_per_team_away(team_id)
    @games.select do |game|
      game.away_team_id == team_id.to_i
    end
  end

  def total_games_per_team_home(team_id)
    @games.select do |game|
      game.home_team_id == team_id.to_i
    end
  end

  def games_by_season
    season_games = @games.group_by do |game|
      game.season
    end
    season_games
  end

  def season_game_ids
    season_game_ids = {}
    games_by_season.map do |season, games|
      season_game_ids[season] = games.map do |game|
        game.game_id
      end
    end
    season_game_ids
  end

  def count_of_teams
    @games.map do |game|
      game.away_team_id
      game.home_team_id
    end.uniq.count
  end

  def game_ids_by_season(season_id)
    season_games = @games.find_all do |game|
      game.season == season_id
    end
    season_games.map do |game|
      game.game_id.to_s
    end
  end

  def highest_total_score
    max_score_game = @games.max_by do |game|
      game.away_goals + game.home_goals
    end
    max_score_game.home_goals + max_score_game.away_goals
  end

  def lowest_total_score
    min_score_game = @games.min_by do |game|
      game.away_goals + game.home_goals
    end
    min_score_game.home_goals + min_score_game.away_goals
  end

  def calc_wins(home_or_away)
    @games.count do |game|
      game.calculate_winner == home_or_away
    end
  end

  def percentage_home_wins
    home_wins = calc_wins(:home)
    (home_wins.to_f / @games.count).round(2)
  end

  def percentage_visitor_wins
    visitor_wins = calc_wins(:away)
    (visitor_wins.to_f / @games.count).round(2)
  end

  def percentage_ties
    ties = calc_wins(:tie)
    (ties.to_f / @games.count).round(2)
  end

  def count_of_games_by_season
    count = {}
    games_by_season.map do |season, games|
      count[season] = games.count
    end
    count
  end

  def average_goals_per_game
    total_goals = @games.map do |game|
      game.away_goals + game.home_goals
    end
    (total_goals.sum.to_f / total_goals.count).round(2)
  end

  def average_goals_by_season
    average_goals = {}

    games_by_season.map do |season, games|
      numerator = (games.sum {|game| game.away_goals + game.home_goals }).to_f
      denominator = games.count
      average_goals[season] = (numerator / denominator).round(2)
    end

    average_goals
  end

  def wins_per_season_by_team(team_id)
    wins_by_season = Hash.new(0)

    total_games_per_team_home(team_id).each do |game|
      if game.calculate_winner == :home
        wins_by_season[game.season] += 1
      end
    end
    total_games_per_team_away(team_id).each do |game|
      if game.calculate_winner == :away
        wins_by_season[game.season] += 1
      end
    end
    wins_by_season
  end

  def win_perc(team_id)
    win_percentage = {}
    wins_per_season_by_team(team_id).each do |season, win_number|
      numerator = win_number.to_f 
      l_value = total_games_per_team_home(team_id).count
      r_value = total_games_per_team_away(team_id).count
      denominator = (l_value + r_value)
      win_percentage[season] = ((numerator / denominator) * 100).round(2)
    end
    win_percentage
  end

  def best_season(team_id)
    win_perc(team_id).key(win_perc(team_id).values.max)
  end

  def worst_season(team_id)
    win_perc(team_id).key(win_perc(team_id).values.min)
  end

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

  def games_per_season_by_team(team_id)
    games_by_season = Hash.new(0)
    total_games_per_team = total_games_per_team_away(team_id) + total_games_per_team_home(team_id)
    total_games_per_team.each do |game|
      games_by_season[game.season] += 1
    end
    games_by_season
  end

end