class TaflMoveSerializer < ActiveModel::Serializer
  attributes :id, :from_row, :from_col, :to_row, :to_col, :piece_type, :captured_pieces
end 