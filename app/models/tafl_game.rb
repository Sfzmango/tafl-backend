class TaflGame < ApplicationRecord
  has_many :tafl_moves, dependent: :destroy

  validates :status, presence: true, inclusion: { in: %w[IN_PROGRESS ATTACKER_WIN DEFENDER_WIN] }
  validates :current_turn, presence: true, inclusion: { in: %w[ATTACKER DEFENDER] }
  validates :board, presence: true

  before_validation :set_default_values, on: :create

  private

  def set_default_values
    self.status ||= 'IN_PROGRESS'
    self.current_turn ||= 'ATTACKER'
    self.board ||= initial_board
  end

  def initial_board
    board = Array.new(11) { Array.new(11, 'EMPTY') }
    
    # Set up attackers
    attacker_positions = [
      [0, 3], [0, 4], [0, 5], [0, 6], [0, 7],
      [1, 5],
      [10, 3], [10, 4], [10, 5], [10, 6], [10, 7],
      [9, 5],
      [3, 0], [4, 0], [5, 0], [6, 0], [7, 0],
      [5, 1],
      [3, 10], [4, 10], [5, 10], [6, 10], [7, 10],
      [5, 9]
    ]

    # Set up defenders
    defender_positions = [
      [3, 5], [4, 4], [4, 5], [4, 6],
      [5, 3], [5, 4], [5, 6], [5, 7],
      [6, 4], [6, 5], [6, 6],
      [7, 5]
    ]

    # Place pieces on the board
    attacker_positions.each do |row, col|
      board[row][col] = 'ATTACKER'
    end

    defender_positions.each do |row, col|
      board[row][col] = 'DEFENDER'
    end

    # Place the king
    board[5][5] = 'KING'

    board
  end
end
