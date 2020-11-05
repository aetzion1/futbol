require_relative './game_teams'
require_relative './game_teams_repo'

class GameTeamsRepoHelper
    def initialize(game_teams_path, repo)
        @game_teams = make_game_teams(game_teams_path)
        @repo = repo
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

    def games_teams_by_team_id(arg_id)
       test = []
        @game_teams.each do |game|
            test << game unless game.team_id != arg_id
        end
        test
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
  
    def game_teams_by_coach
      @game_teams.group_by do |game|
        game.head_coach
      end
    end
  
    def games_by_team_id(season_id)
      game_by_id = game_team_by_season(season_id)
      game_by_id.group_by do |game|
        game.team_id
      end
      game_by_id
    end

    # def games_by_team_by_season(season_id)
    #     game_team_by_season(season_id)
    #     
    # end
  
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
      game_ids = @repo.season_game_ids
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

  def goals_sum
    test = @game_teams.game_teams_by_team
    average_goals = {}
    test.map do |team , games|
      average_goals[team] = (games.sum {|game|  game.goals}).to_f / games.count
    end
    average_goals
  end

  
  def games_sum(hoa_state)
    test = @game_teams.game_teams_by_hoa(hoa_state)
    average_goals = {}

    test.map do |team , games|
      average_goals[team] = (games.sum {|game|  game.goals}).to_f / games.count
    end 
    average_goals
  end

  
  def tackles_for_team(season_id)
    team_tackles = {}
    test_arr = games_by_team_id(season_id)
    
    test_arr.map do |games|
        tackles = 0
        tackles += games.tackles
        team_tackles[games.game_id] = tackles
    end
    team_tackles
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

end