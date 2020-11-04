require './test/test_helper'

class GameTeamsTest < MiniTest::Test
    
    def setup
        csv = CSV.read('./dummy_data/game_teams_dummy.csv', headers: true, header_converters: :symbol)
        @game_teams = csv.map do |row|
          GameTeams.new(row)
        end
    end

    def test_it_exists_with_attributes
        assert_instance_of GameTeams, @game_teams.first
        assert_equal "game1", @game_teams.first.game_id
        assert_equal "1", @game_teams.first.team_id
        assert_equal "away", @game_teams.first.hoa
        assert_equal "WIN", @game_teams.first.result
        assert_equal "REG", @game_teams.first.settled_in
        assert_equal "Coach Phil", @game_teams.first.head_coach
        assert_equal 7, @game_teams.first.goals
        assert_equal 8, @game_teams.first.shots
        assert_equal 33, @game_teams.first.tackles
        assert_equal 14, @game_teams.first.pim
        assert_equal 5, @game_teams.first.powerplayopportunities
        assert_equal 1, @game_teams.first.powerplaygoals
        assert_equal 37.2, @game_teams.first.faceoffwinpercentage
        assert_equal 11, @game_teams.first.giveaways
        assert_equal 8, @game_teams.first.takeaways
    end
end