class Move
  include Comparable

  VALUES = %w(rock paper scissors lizard Spock)

  RULES = {
    'rock' => %w(lizard scissors),
    'lizard' => %w(paper Spock),
    'scissors' => %w(paper lizard),
    'Spock' => %w(scissors rock),
    'paper' => %w(Spock rock)
  }

  attr_reader :value

  def initialize(value)
    @value = value
  end

  def to_s
    value
  end

  def >(other_move)
    RULES[value].include?(other_move.value)
  end

  def ==(other_move)
    value == other_move.value
  end
end

class Player
  attr_accessor :move, :name, :score, :win

  def initialize
    @move = nil
    set_name
    @score = 0
    @win = false
  end
end

class Human < Player
  def set_name
    n = ''
    loop do
      puts "What's your name?"
      n = gets.chomp
      break unless n.empty?
      puts "Sorry, must enter a value."
    end
    self.name = n
  end

  def choose
    choice = nil
    loop do
      puts "Please choose rock, paper, scissors, lizard, or Spock:"
      choice = gets.chomp
      break if Move::VALUES.include?(choice)
      puts "Sorry, invalid choice."
    end
    self.move = Move.new(choice)
  end
end

class Computer < Player
  def set_name
    self.name = %w(R2D2 Hal Chappie Sonny Number5).sample
  end

  def choose
    self.move = Move.new(Move::VALUES.sample)
  end
end

class RPSGame
  attr_accessor :human, :computer

  def initialize
    @human = Human.new
    @computer = Computer.new
  end

  def display_welcome_message
    puts "Welcome to Rock, Paper, Scissors, Lizard, Spock!"
  end

  def display_goodbye_message
    if human.win
      puts "#{human.name} is the overall winner."
    elsif computer.win
      puts "#{computer.name} is the overall winner."
    end

    puts "Thanks for playing Rock, Paper, Scissors, Lizard, Spock. Good bye!"
  end

  def display_moves
    puts "#{human.name} chose #{human.move}"
    puts "#{computer.name} chose #{computer.move}"
  end

  def display_winner
    if human.move > computer.move
      puts "#{human.name} won!"
    elsif human.move == computer.move
      puts "It's a tie!"
    else
      puts "#{computer.name} won!"
    end
  end

  def update_scores
    if human.move > computer.move
      human.score += 1
    elsif computer.move > human.move
      computer.score += 1
    end
  end

  def play_again?
    answer = nil
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp
      break if %w(y n).include?(answer.downcase)
      puts "Sorry, must input y or n."
    end

    answer == 'y'
  end

  def take_turn
    human.choose
    computer.choose
    update_scores
  end

  def display_scores
    puts "#{human.name}: #{human.score}"
    puts "#{computer.name}: #{computer.score}"
  end

  def display_turn
    display_moves
    display_winner
    display_scores
  end

  def check_for_win
    if human.score >= 10
      human.win = true
    elsif computer.score >= 10
      computer.win = true
    end
  end

  def play
    loop do
      display_welcome_message
      take_turn
      display_turn
      check_for_win
      break if human.win || computer.win
      break unless play_again?
    end
    display_goodbye_message
  end
end

RPSGame.new.play
