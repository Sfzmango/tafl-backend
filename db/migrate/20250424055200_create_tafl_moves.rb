class CreateTaflMoves < ActiveRecord::Migration[8.0]
  def change
    create_table :tafl_moves do |t|
      t.references :tafl_game, null: false, foreign_key: true
      t.integer :from_row
      t.integer :from_col
      t.integer :to_row
      t.integer :to_col
      t.string :piece_type
      t.json :captured_pieces

      t.timestamps
    end
  end
end
