class TaflGameSerializer < ActiveModel::Serializer
  attributes :id, :status, :current_turn, :board
  has_many :tafl_moves

  def board
    object.board
  end
end 