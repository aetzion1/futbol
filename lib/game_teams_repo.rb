require 'CSV'
# require_relative './game_teams'
# require_relative './stat_tracker'

class GameTeamsRepo

    def initialize(game_teams_path)
        @game_teams = make_game_teams(game_teams_path)
    end

    def make_game_teams(game_teams_path)
        game_teams = []
  
        CSV.foreach(game_teams_path, headers: true, header_converters: [:symbol , :downcase]   ) do |row|
            game_id = row[:game_id]
            team_id = row[:team_id]
            hoa = row[:hoa]
            result = row[:result]
            settled_in = row[:settled_in]
            head_coach = row[:head_coach]
            goals = row[:goals].to_i
            shots = row[:shots].to_i
            tackles = row[:tackles].to_i
            pim = row[:pim].to_i
            powerPlayOpportunities = row[:powerPlayOpportunities].to_i
            powerPlayGoals = row[:powerPlayGoals].to_i
            faceOffWinPercentage = row[:faceOffWinPercentage].to_f
            giveaways = row[:giveaways].to_i
            takeaways = row[:takeaways].to_i
            game_teams << GameTeams.new(game_id,team_id,hoa,result,settled_in,head_coach,goals,shots,tackles,pim,powerPlayOpportunities,powerPlayGoals,faceOffWinPercentage,giveaways,takeaways)
        end
        game_teams
      end  

    def game_teams_by_home
        @game_teams.group_by do |game|
            game.team_id unless game.hoa == "away"
        end
    end

    def highest_scoring_home_team
        average_goals = {}
        home_games = game_teams_by_home
        home_games.map do |team , games|
         average_goals[team] = (games.sum {|game|  game.goals}).to_f / games.count
        end
        best_home = average_goals.key(average_goals.values.max)
        match = @teams.find do |team|
          team.team_id == best_home
        end
        match.teamname
      end

end
