class Game

  attr_accessor :board, :lost, :r_count
  def initialize(num_bombs)
    @new_board = Board.new
    @new_board.place_bombs(num_bombs)
    @board = @new_board.board
    @lost = false
    @r_count = 0
    @num_bombs = num_bombs
  end

  def move(action, position)
    if action == "flag"
      flag(position)
    elsif action == "reveal"
      reveal(position)
    elsif action == "unflag"
      unflag(position)
    end
  end

  def flag(position)
    tile = @board[position[0]][position[1]]
    tile.flag_status =  true unless tile.reveal_status == true
  end

  def unflag(position)
    tile = @board[position[0]][position[1]]
    tile.flag_status =  false unless tile.reveal_status == true
  end

  def reveal(position)
    tile = @board[position[0]][position[1]]
    if tile.reveal_status == true
      return
    end
    unless tile.flag_status == true
      tile.reveal_status = true
      @r_count += 1
    end
    @new_board.adjacent_bombs(tile)
    if tile.adjacent_bombs > 0
      return tile.adjacent_bombs
    end

    @new_board.neighbors(tile).each do |neighbor_tile|
      if tile.adjacent_bombs == 0
        reveal(neighbor_tile.position)
      end
    end
  end

  def display
    display_board = []
    @board.each_with_index do |row, row_number|
      display_board << []
      row.each do |tile|
        if tile.reveal_status == false
          if tile.flag_status == false
            display_board[row_number] << '*'
          else
            display_board[row_number] << 'F'
          end
        else
          if tile.bomb_status == false
            if tile.adjacent_bombs == 0
              display_board[row_number] << '_'
            else
              display_board[row_number] << tile.adjacent_bombs.to_s
            end
          else
            display_board[row_number] << 'B'
            @lost = true
          end
        end
      end
    end
    display_board.each do |row|
      print "#{row} \n"
    end
  end

  def run

    until game_over?
      puts "Choose a row."
      row = gets.chomp.to_i - 1
      puts "Choose a column."
      column = gets.chomp.to_i - 1
      position = [row, column]
      puts "Choose an action: Flag, unflag, reveal"
      action = gets.chomp

      move(action, position)

      display
    end

    if won?
      puts "Yay!"
    else

      puts "You suck :("
    end
  end

  def game_over?
    won? || lost?
  end

  def won?
    @lost == false && @r_count + @num_bombs == 81
  end

  def lost?
    @lost
  end

end

class Tile
  attr_accessor :position, :bomb_status, :flag_status, :reveal_status,
                :adjacent_bombs, :neighbors

  def initialize(position)
    @position = position
    @bomb_status = false
    @flag_status = false
    @reveal_status = false
    @adjacent_bombs = 0
  end

end

class Board

  attr_accessor :board
  def initialize
    @board = make_board
  end

  def place_bombs(num)
    positions = []
    while positions.length < num

      random_tile = @board[rand(8)][rand(8)]
      positions << random_tile unless positions.include?(random_tile)
    end

    positions.each do |pos|
      pos.bomb_status = true
    end

  end

  def make_board
    board = Array.new(9) { [] }
    board.each_with_index do |row, row_number|
      (0..8).each do |col_number|
        row << Tile.new([row_number, col_number])
      end
    end
    board
  end

  def neighbors(tile)
    neighbors = []
    tile_row = tile.position[0]
    tile_column = tile.position[1]
    [tile_row - 1, tile_row, tile_row + 1].each do |row|
      [tile_column - 1, tile_column, tile_column + 1].each do |column|
        unless tile_row == row && tile_column == column
          if row.between?(0, 8) && column.between?(0, 8)
            neighbors << @board[row][column]
          end
        end
      end
    end
    neighbors
  end

  def adjacent_bombs(tile)
    neighbors(tile).each do |neighbor|
      if neighbor.bomb_status
        tile.adjacent_bombs += 1
      end
    end

  end
end
