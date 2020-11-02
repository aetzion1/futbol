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

#REMEMBER TO REFACTOR THESE
  def game_teams_by_team
      @game_teams.group_by do |game|
        game.team_id
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

  def winningest_coach(season_id)
    game_set = @stat_tracker.game_ids_by_season(season_id)
    game_teams_set = game_teams_by_coach

    win_rate = {}
    game_teams_set.map do |coach, games|
      win_rate[coach] = ((games.count {|game| (game.result == "WIN") && game_set.include?(game.game_id)}).to_f / (games.count {|game| game_set.include?(game.game_id)})).round(2)
    end

    win_rate.key(win_rate.values.reject{|x| x.nan?}.max)
  end

  def worst_coach(season_id)
    game_set = @stat_tracker.game_ids_by_season(season_id)
    game_teams_set = game_teams_by_coach

    win_rate = {}
    game_teams_set.map do |coach, games|
      win_rate[coach] = ((games.count {|game| (game.result == "WIN") && game_set.include?(game.game_id)}).to_f / (games.count {|game| game_set.include?(game.game_id)})).round(2)
    end
    
    win_rate.key(win_rate.values.reject{|x| x.nan?}.min)
  end

  def game_ids_by_season(season_id)
    @stat_tracker.game_team_by_season(season_id)
  end

  def game_team_by_season(season_id)
    game_ids = @stat_tracker.season_game_ids
    @game_teams.find_all do |row|
      game_ids[season_id].include?(row.game_id)
    end
  end

  def games_by_team_id(season_id)
    game_by_id = game_team_by_season(season_id).group_by do |game|
      game.team_id
    end
    game_by_id
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
    ratio = team_conversion_percent(season_id)
    data_collector = ratio.max_by do |team, ratio|
      ratio
    end
    @stat_tracker.team_name(data_collector[0])
  end

  def least_accurate_team(season_id)
    ratio = team_conversion_percent(season_id)
    data_collector = ratio.min_by do |team, ratio|
      ratio
    end
    @stat_tracker.team_name(data_collector[0])
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

  def best_offense
    average_goals = {}
    game_teams_by_team.map do |team , games|
      average_goals[team] = (games.sum {|game|  game.goals}).to_f / games.count
    end
    best_team = average_goals.key(average_goals.values.max)
    @stat_tracker.team_name(best_team)
  end

  def worst_offense
    average_goals = {}
    game_teams_by_team.map do |team , games|
      average_goals[team] = (games.sum {|game|  game.goals}).to_f / games.count
    end
    worst_team = average_goals.key(average_goals.values.min)
    @stat_tracker.team_name(worst_team)
  end

  def highest_scoring_visitor
    average_goals = {}
    game_teams_by_away.map do |team , games|
      average_goals[team] = (games.sum {|game|  game.goals}).to_f / games.count
    end 
    best_visit = average_goals.key(average_goals.values.max)
    @stat_tracker.team_name(best_visit)
  end

  def highest_scoring_home_team
    average_goals = {}
    game_teams_by_home.map do |team , games|
      average_goals[team] = (games.sum {|game|  game.goals}).to_f / games.count
    end
    best_home = average_goals.key(average_goals.values.max)
    @stat_tracker.team_name(best_home)
  end

  def lowest_scoring_visitor
    average_goals = {}
    game_teams_by_away.map do |team , games|
      average_goals[team] = (games.sum {|game|  game.goals}).to_f / games.count
    end
    worst_visit = average_goals.key(average_goals.values.min)
    @stat_tracker.team_name(worst_visit)
  end

  def lowest_scoring_home_team
    average_goals = {}
    game_teams_by_home.map do |team , games|
      average_goals[team] = (games.sum {|game|  game.goals}).to_f / games.count
    end
    worst_home = average_goals.key(average_goals.values.min)
    @stat_tracker.team_name(worst_home)
  end

  def most_tackles(season_id)
    team_tackles = {}
    games_by_team_id(season_id).map do |team, games|
      tackles = 0
      games.map do |game|
        tackles += game.tackles
      end
      team_tackles[team] = tackles
    end
    @stat_tracker.team_name(team_tackles.key(team_tackles.values.max))
  end

  def fewest_tackles(season_id)
    team_tackles = {}
    games_by_team_id(season_id).map do |team, games|
      tackles = 0
      games.map do |game|
        tackles += game.tackles
      end
      team_tackles[team] = tackles
    end

    @stat_tracker.team_name(team_tackles.key(team_tackles.values.min))
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