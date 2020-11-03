require './test/test_helper'

class TeamsTest < Minitest::Test

  def test_it_exists
    team = Teams.new(row = {})
    row[:team_id] = '123'
     row[:franchiseid] = '234'
     row[:teamname] = 'Jabberwokkies'
     row[:abbreviation] = 'JBW'
     row[:stadium] = 'HOUZE'
     row[:link] = 'ZELDA'

    assert_instance_of Teams, team
  end

end