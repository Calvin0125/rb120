class Board
  attr_accessor :human_marker, :computer_marker

  @@human_marker = "X"
  @@computer_marker = "0"

  WINNING_LINES = [[1, 2, 3], [4, 5, 6], [7, 8, 9]] +
                  [[1, 4, 7], [2, 5, 8], [3, 6, 9]] +
                  [[1, 5, 9], [3, 5, 7]]

  def initialize
    @squares = {}
    reset
  end

  def self.human_marker
    @@human_marker
  end

  def self.human_marker=(marker)
    @@human_marker = marker
  end

  def self.computer_marker
    @@computer_marker
  end

  def self.computer_marker=(marker)
    @@computer_marker = marker
  end

  # rubocop:disable Metrics/AbcSize
  # rubocop:disable Metrics/MethodLength
  def draw
    puts "     |     |"
    puts "  #{@squares[1]}  |  #{@squares[2]}  |  #{@squares[3]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[4]}  |  #{@squares[5]}  |  #{@squares[6]}"
    puts "     |     |"
    puts "-----+-----+-----"
    puts "     |     |"
    puts "  #{@squares[7]}  |  #{@squares[8]}  |  #{@squares[9]}"
    puts "     |     |"
  end
  # rubocop:enable Metrics/AbcSize
  # rubocop:enable Metrics/MethodLength

  def reset
    (1..9).each { |key| @squares[key] = Square.new }
  end

  def []=(key, marker)
    @squares[key].marker = marker
  end

  def unmarked_keys
    @squares.keys.select { |key| @squares[key].unmarked? }
  end

  def full?
    unmarked_keys.empty?
  end

  def someone_won?
    !!winning_marker
  end

  def empty_square(line)
    empty_square = @squares.select do |k, v|
      line.include?(k) && v.marker == Square::INITIAL_MARKER
    end
    empty_square.keys[0]
  end

  def computer_defense
    WINNING_LINES.each do |line|
      markers = @squares.values_at(*line).map(&:marker)
      if markers.count(@@human_marker) == 2 &&
         markers.count(Square::INITIAL_MARKER) == 1
        return empty_square(line)
      end
    end
    nil
  end

  def computer_offense
    WINNING_LINES.each do |line|
      markers = @squares.values_at(*line).map(&:marker)
      if markers.count(@@computer_marker) == 2 &&
         markers.count(Square::INITIAL_MARKER) == 1
        return empty_square(line)
      end
    end
    nil
  end

  def middle?
    @squares[5].marker == Square::INITIAL_MARKER
  end

  def winning_marker
    WINNING_LINES.each do |line|
      markers = @squares.values_at(*line).map(&:marker)
      if markers.include?(' ') == false && markers.uniq.length == 1
        return markers[0]
      end
    end
    nil
  end
end

class Square
  attr_accessor :marker

  INITIAL_MARKER = ' '

  def initialize(marker = INITIAL_MARKER)
    @marker = marker
  end

  def to_s
    @marker
  end

  def unmarked?
    marker == INITIAL_MARKER
  end
end

class Player
  attr_accessor :marker, :name

  def initialize(marker, name = nil)
    @marker = marker
    @name = name
  end
end

class TTTGame
  private

  attr_reader :board, :human, :computer

  FIRST_TO_MOVE = Board.human_marker

  def initialize
    @board = Board.new
    @human = Player.new(Board.human_marker)
    @computer = Player.new(Board.computer_marker, %w(R2D2 C3PO Hal).sample)
    @current_marker = FIRST_TO_MOVE
    @human_score = 0
    @computer_score = 0
  end

  def update_score
    winning_marker = board.winning_marker
    @computer_score += 1 if winning_marker == computer.marker
    @human_score += 1 if winning_marker == human.marker
  end

  def clear
    system 'clear'
  end

  def display_welcome_message
    clear
    puts "Welcome to Tic Tac Toe!"
    puts ""
  end

  def display_goodbye_message
    puts "Thanks for playing Tic Tac Toe! Goodbye!"
  end

  def display_board
    puts "#{human.name} is an #{human.marker}. " \
         "#{computer.name} is an #{computer.marker}."
    puts ""
    board.draw
    puts ""
  end

  def clear_screen_and_display_board
    clear
    puts "#{human.name} is an #{human.marker}. " \
         "#{computer.name} is an #{computer.marker}."
    puts ""
    board.draw
    puts ""
  end

  def joinor(squares)
    case squares.length
    when 1
      squares[0]
    when 2
      "#{squares[0]} or #{squares[1]}"
    else
      squares[-1] = "or #{squares.last}"
      squares.join(', ')
    end
  end

  def human_moves
    puts "Choose a square (#{joinor(board.unmarked_keys)}):"
    square = 0
    loop do
      square = gets.chomp.to_i
      break if board.unmarked_keys.include?(square)
      puts "Sorry, that's not a valid choice."
    end

    board[square] = human.marker
  end

  def computer_moves
    square = if board.computer_offense
               board.computer_offense
             elsif board.computer_defense
               board.computer_defense
             elsif board.middle?
               5
             else
               board.unmarked_keys.sample
             end
    board[square] = computer.marker
  end

  def current_player_moves
    if human_turn?
      human_moves
      @current_marker = computer.marker
    else
      computer_moves
      @current_marker = human.marker
    end
  end

  def display_result
    clear_screen_and_display_board

    case board.winning_marker
    when human.marker
      puts "You won!"
    when computer.marker
      puts "Computer won!"
    else
      puts "It's a tie!"
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include?(answer)
      puts "Sorry, must input y or n"
    end
    answer == 'y'
  end

  def reset
    board.reset
    @current_marker = FIRST_TO_MOVE
    clear
  end

  def display_play_again_message
    puts "Let's play again!"
    puts ""
  end

  def human_turn?
    @current_marker == human.marker
  end

  def player_move
    loop do
      current_player_moves
      break if board.someone_won? || board.full?
      clear_screen_and_display_board if human_turn?
    end
  end

  def display_score
    puts "#{human.name}: #{@human_score}"
    puts "#{computer.name}: #{@computer_score}"
  end

  def choose_marker
    answer = ''
    loop do
      puts "Choose X or O"
      answer = gets.chomp.upcase
      break if %w(X O).include?(answer)
      puts "Sorry, you must input X or O."
    end
    answer
  end

  def update_markers(human_marker)
    computer_marker = human_marker == 'X' ? 'O' : 'X'
    Board.human_marker = human_marker
    human.marker = human_marker
    Board.computer_marker = computer_marker
    computer.marker = computer_marker
  end

  def update_and_display_after_round
    display_result
    update_score
    display_score
  end

  def main_game
    loop do
      update_markers(choose_marker)
      display_board
      player_move
      update_and_display_after_round
      break if @human_score == 5 || @computer_score == 5
      break unless play_again?
      reset
      display_play_again_message
    end
  end

  def display_overall_winner
    if @computer_score == 5
      puts "The computer is the overall winner!"
    elsif @human_score == 5
      puts "You are the overall winner!"
    end
  end

  def reset_game_and_score
    reset
    @human_score = 0
    @computer_score = 0
  end

  def play_to_five_again?
    answer = ''
    loop do
      puts "Play to five again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include?(answer)
      puts "Sorry, must input y or n."
    end
    answer == 'y'
  end

  def update_user_name
    name = ''
    loop do
      puts "Please enter your name."
      name = gets.chomp
      break unless name == ' '
    end
    human.name = name
  end

  public

  def play
    display_welcome_message
    update_user_name
    loop do
      main_game
      display_overall_winner
      break if @computer_score < 5 && @human_score < 5
      break unless play_to_five_again?
      reset_game_and_score
    end
    display_goodbye_message
  end
end

game = TTTGame.new
game.play
