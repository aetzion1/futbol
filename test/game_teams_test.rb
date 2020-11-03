require './test/test_helper'

class GameTeamsTest < MiniTest::Test
    
    def setup
        csv = CSV.read('./dummy_data/game_teams_dummy.csv', headers: true, header_converters: :symbol)
        @game_teams = csv.map do |row|
          GameTeams.new(row)
        end
    end

    def test_it_exists
        assert_instance_of GameTeams, @game_teams.first
    end
end