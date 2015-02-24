require 'yaml'

class Game

  attr_accessor :board, :lost, :r_count
  def initialize(num_bombs, board_size)
    @new_board = Board.new(board_size)
    @new_board.place_bombs(num_bombs)
    @board = @new_board.board
    @lost = false
    @r_count = 0
    @num_bombs = num_bombs
    @board_size = board_size
    @save_time = 0
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
    start_time = Time.now
    until game_over?
      display
      puts "Choose an action: Flag, unflag, reveal, save"
      action = gets.chomp
      if action == "save"
        @save_time = Time.now - start_time
        File.open("minesweeper_game.yml", "w") do |f|
          f.puts self.to_yaml
        end
        return
      end
      puts "Choose a row."
      row = gets.chomp.to_i - 1
      puts "Choose a column."
      column = gets.chomp.to_i - 1
      position = [row, column]

      move(action, position)


    end
    end_time = Time.now + @save_time
    display

    if won?
      puts "Yay!"
      puts "It took you #{end_time - start_time} seconds!"
    else
      puts "You suck :("
    end
  end

  def game_over?
    won? || lost?
  end

  def won?
    @lost == false && @r_count + @num_bombs == @board_size ** 2
  end

  def lost?
    @lost
  end

  def self.load
    file = File.read("minesweeper_game.yml")
    YAML::load(file)
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

  attr_accessor :board, :board_size
  def initialize(board_size)
    @board = make_board(board_size)
    @board_size = board_size
  end

  def place_bombs(num)
    positions = []
    while positions.length < num

      random_tile = @board[rand(@board_size - 1)][rand(@board_size - 1)]
      positions << random_tile unless positions.include?(random_tile)
    end

    positions.each do |pos|
      pos.bomb_status = true
    end

  end

  def make_board(board_size)
    board = Array.new(board_size) { [] }
    board.each_with_index do |row, row_number|
      (0..(board_size - 1)).each do |col_number|
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
          if row.between?(0, (@board_size - 1)) && column.between?(0, (@board_size - 1))
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
