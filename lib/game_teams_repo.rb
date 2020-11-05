require_relative './game_teams'

class GameTeamsRepo

  def initialize(game_teams_path, stat_tracker)
    @game_teams = make_game_teams(game_teams_path)
    @stat_tracker = stat_tracker
  end
  
  def make_game_teams(game_teams_path)
    game_teams = []
    CSV.foreach(game_teams_path, headers: true, header_converters: :symbol) do |row|
      game_teams << GameTeams.new(row)
    end
    game_teams
  end

  def game_teams_by_team
      @game_teams.group_by do |game|
        game.team_id
      end
  end

  def game_teams_by_hoa(hoa_state)
    if hoa_state == "away"
      @game_teams.group_by do |game|
        game.team_id unless game.hoa == "home"
      end
    else hoa_state == "home"
      @game_teams.group_by do |game|
        game.team_id unless game.hoa == "away"
      end
    end
  end

  def game_teams_by_away
    @game_teams.group_by do |game|
      game.team_id unless game.hoa == "home"
    end
  end
  
  def game_teams_by_home
    @game_teams.group_by do |game|
      game.team_id unless game.hoa == "away"
    end
  end

  def game_teams_by_coach
    @game_teams.group_by do |game|
      game.head_coach
    end
  end

  def games_by_team_id(season_id)
    game_by_id = game_team_by_season(season_id).group_by do |game|
      game.team_id
    end
    game_by_id
  end

  def game_teams_by_team_id
    game_set = {}
    team_set = game_teams_by_team

    team_set.map do |team, games|
      game_set[team] = games.map do |game|
        game.game_id
      end
    end

    game_set
  end

  def game_team_by_season(season_id)
    game_ids = @stat_tracker.season_game_ids
    @game_teams.find_all do |row|
      game_ids[season_id].include?(row.game_id)
    end
  end

  def win_rate(game_set, game_teams_set)
    winrate = {}
    game_teams_set.map do |coach, games|
      numerator = (games.count {|game| (game.result == "WIN") && game_set.include?(game.game_id)}).to_f
      denominator = games.count {|game| game_set.include?(game.game_id)}
      winrate[coach] = (numerator / denominator).round(2)
    end
    winrate
  end

  def winningest_coach(season_id)
    game_set = @stat_tracker.game_ids_by_season(season_id)
    game_teams_set = game_teams_by_coach
    win_rate(game_set, game_teams_set).key(win_rate(game_set, game_teams_set).values.reject{|x| x.nan?}.max)
  end

  def worst_coach(season_id)
    game_set = @stat_tracker.game_ids_by_season(season_id)
    game_teams_set = game_teams_by_coach
    win_rate(game_set, game_teams_set).key(win_rate(game_set, game_teams_set).values.reject{|x| x.nan?}.min)
  end

  
  def team_conversion_percent(season_id)
    team_ratio = {}
    season_id_games = games_by_team_id(season_id)

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
    test = game_teams_by_team
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
    test = game_teams_by_hoa(hoa_state)
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
    
    test = games_by_team_id(season_id)
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
    goals = 0
    team_set = game_teams_by_team

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
    team_set = game_teams_by_team

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
    game_set = game_teams_by_team_id[team_id]
    team_set = game_teams_by_team
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
    @stat_tracker.team_name(fav)
  end

  def rival(team_id)
    game_set = game_teams_by_team_id[team_id]
    team_set = game_teams_by_team
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
    @stat_tracker.team_name(fav)
  end

end