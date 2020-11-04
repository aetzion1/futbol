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
end