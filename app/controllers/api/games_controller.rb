module Api
  class GamesController < BaseController
    def create
      game = TaflGame.create!
      render_success(game)
    end

    def show
      game = TaflGame.find(params[:id])
      render_success(game)
    end

    def make_move
      game = TaflGame.find(params[:id])
      move = game.tafl_moves.build(move_params)

      # Check if the target position is empty
      if game.board[move.to_row][move.to_col] != 'EMPTY'
        render_error('Cannot move onto another piece')
        return
      end

      if move.save
        new_board = update_board(game.board, move)
        captured_pieces = check_captures(new_board, move)
        
        if captured_pieces.any?
          move.update!(captured_pieces: captured_pieces)
          captured_pieces.each do |pos|
            new_board[pos[:row]][pos[:col]] = 'EMPTY'
          end
        end

        game.update!(
          current_turn: game.current_turn == 'ATTACKER' ? 'DEFENDER' : 'ATTACKER',
          board: new_board,
          status: check_game_status(new_board)
        )
        
        render_success(game)
      else
        render_error(move.errors.full_messages.join(', '))
      end
    end

    private

    def move_params
      params.require(:move).permit(:from_row, :from_col, :to_row, :to_col, :piece_type)
    end

    def update_board(board, move)
      new_board = board.deep_dup
      new_board[move.to_row][move.to_col] = move.piece_type
      new_board[move.from_row][move.from_col] = 'EMPTY'
      new_board
    end

    def check_captures(board, move)
      captured_pieces = []
      directions = [[-1, 0], [1, 0], [0, -1], [0, 1]]
      
      # Check for captures in all four directions
      directions.each do |d_row, d_col|
        # Check the position immediately next to where the piece moved to
        adj_row = move.to_row + d_row
        adj_col = move.to_col + d_col
        
        # Skip if position is invalid or empty
        next unless valid_position?(adj_row, adj_col)
        adj_piece = board[adj_row][adj_col]
        next if adj_piece == 'EMPTY'
        
        # Skip if not an enemy piece
        next unless (move.piece_type == 'ATTACKER' && adj_piece == 'DEFENDER') ||
                   (move.piece_type == 'DEFENDER' && adj_piece == 'ATTACKER')
        
        # Check the next position in the same direction
        support_row = adj_row + d_row
        support_col = adj_col + d_col
        
        # Skip if this is where the piece moved from (to prevent capturing by moving through)
        next if support_row == move.from_row && support_col == move.from_col
        
        if valid_position?(support_row, support_col)
          support_piece = board[support_row][support_col]
          
          # Capture if sandwiched between two pieces of the same type
          if support_piece == move.piece_type && adj_piece != 'KING'
            captured_pieces << { row: adj_row, col: adj_col }
          end
        end
        
        # Check for captures against restricted squares
        if is_restricted_square(support_row, support_col)
          if support_row == 5 && support_col == 5  # Throne
            # Only attackers can use empty throne for capture
            if board[5][5] == 'EMPTY' && move.piece_type == 'ATTACKER'
              captured_pieces << { row: adj_row, col: adj_col }
            end
          else  # Corner squares
            captured_pieces << { row: adj_row, col: adj_col }
          end
        end
      end
      
      captured_pieces
    end

    def check_game_status(board)
      # Check if king is in a corner (defender win)
      corner_positions = [[0, 0], [0, 10], [10, 0], [10, 10]]
      corner_positions.each do |row, col|
        return 'DEFENDER_WIN' if board[row][col] == 'KING'
      end

      # Check if king is captured (attacker win)
      king_position = find_king_position(board)
      if king_position
        row, col = king_position
        if is_king_captured?(board, row, col)
          return 'ATTACKER_WIN'
        end
      end

      # Check if king and all defenders are encircled (attacker win)
      if is_king_encircled?(board)
        return 'ATTACKER_WIN'
      end

      # Check if current player has no valid moves (opponent win)
      if no_valid_moves?(board)
        return board.current_turn == 'ATTACKER' ? 'DEFENDER_WIN' : 'ATTACKER_WIN'
      end

      'IN_PROGRESS'
    end

    def valid_position?(row, col)
      row.between?(0, 10) && col.between?(0, 10)
    end

    def is_restricted_square(row, col)
      # Throne and corners are restricted squares
      (row == 5 && col == 5) || # Throne
      (row == 0 && col == 0) || # Top-left corner
      (row == 0 && col == 10) || # Top-right corner
      (row == 10 && col == 0) || # Bottom-left corner
      (row == 10 && col == 10) # Bottom-right corner
    end

    def find_king_position(board)
      board.each_with_index do |row, row_index|
        row.each_with_index do |piece, col_index|
          return [row_index, col_index] if piece == 'KING'
        end
      end
      nil
    end

    def is_king_encircled?(board)
      # Find all defender positions
      defender_positions = []
      board.each_with_index do |row, row_index|
        row.each_with_index do |piece, col_index|
          defender_positions << [row_index, col_index] if piece == 'DEFENDER' || piece == 'KING'
        end
      end

      # Get all positions that need to be checked for attackers
      positions_to_check = Set.new
      defender_positions.each do |row, col|
        # Add all positions around each defender
        (-1..1).each do |d_row|
          (-1..1).each do |d_col|
            next if d_row == 0 && d_col == 0 # Skip the defender's position itself
            new_row = row + d_row
            new_col = col + d_col
            if valid_position?(new_row, new_col)
              positions_to_check.add([new_row, new_col])
            end
          end
        end
      end

      # Remove positions that are occupied by defenders
      defender_positions.each do |pos|
        positions_to_check.delete(pos)
      end

      # Check if all remaining positions are occupied by attackers
      positions_to_check.all? do |row, col|
        board[row][col] == 'ATTACKER'
      end
    end

    def is_king_captured?(board, king_row, king_col)
      # Check if king is the only defender piece
      if is_king_only_defender?(board)
        # If king is the only defender, he can be captured on the edge
        # but only if he's completely surrounded by attackers
        return is_surrounded_by_attackers?(board, king_row, king_col)
      end

      # King cannot be captured on the board edge
      return false if king_row == 0 || king_row == 10 || king_col == 0 || king_col == 10

      # Check if king is next to the throne
      if (king_row - 5).abs <= 1 && (king_col - 5).abs <= 1
        # King needs to be surrounded on three sides if next to throne
        surrounding_pieces = [
          board[king_row - 1][king_col],
          board[king_row + 1][king_col],
          board[king_row][king_col - 1],
          board[king_row][king_col + 1]
        ].compact # Remove nil values for edge positions

        # King can only be captured by attackers
        surrounding_pieces.count('ATTACKER') >= 3
      else
        # King needs to be surrounded on all four sides
        is_surrounded_by_attackers?(board, king_row, king_col)
      end
    end

    def is_king_only_defender?(board)
      defender_count = 0
      board.each do |row|
        row.each do |piece|
          defender_count += 1 if piece == 'DEFENDER' || piece == 'KING'
        end
      end
      defender_count == 1 # Only the king remains
    end

    def is_surrounded_by_attackers?(board, row, col)
      # Get all adjacent positions
      adjacent_positions = [
        [row - 1, col], # up
        [row + 1, col], # down
        [row, col - 1], # left
        [row, col + 1]  # right
      ].select { |r, c| valid_position?(r, c) }

      # Check if all valid adjacent positions are occupied by attackers
      adjacent_positions.all? do |r, c|
        board[r][c] == 'ATTACKER'
      end
    end

    def no_valid_moves?(board)
      # TODO: Implement this method to check if the current player has any valid moves
      false
    end
  end
end 