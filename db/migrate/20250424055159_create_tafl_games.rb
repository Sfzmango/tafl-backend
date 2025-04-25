class CreateTaflGames < ActiveRecord::Migration[8.0]
  def change
    create_table :tafl_games do |t|
      t.string :status
      t.string :current_turn
      t.json :board

      t.timestamps
    end
  end
end
