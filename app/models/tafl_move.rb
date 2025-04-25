class TaflMove < ApplicationRecord
  belongs_to :tafl_game

  validates :from_row, :from_col, :to_row, :to_col, presence: true,
                                                    numericality: { only_integer: true,
                                                                  greater_than_or_equal_to: 0,
                                                                  less_than: 11 }
  
  validates :piece_type, presence: true,
                        inclusion: { in: %w[KING DEFENDER ATTACKER] }

  validate :valid_move_distance
  validate :valid_piece_ownership

  private

  def valid_move_distance
    return unless from_row && from_col && to_row && to_col

    # In Hnefatafl, pieces can only move orthogonally (like a rook in chess)
    unless from_row == to_row || from_col == to_col
      errors.add(:base, 'Pieces can only move horizontally or vertically')
    end
  end

  def valid_piece_ownership
    return unless piece_type && tafl_game

    valid_piece = case tafl_game.current_turn
                 when 'ATTACKER'
                   piece_type == 'ATTACKER'
                 when 'DEFENDER'
                   %w[DEFENDER KING].include?(piece_type)
                 end

    errors.add(:piece_type, 'does not belong to the current player') unless valid_piece
  end
end
