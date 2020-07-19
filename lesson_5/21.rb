require 'colorize'
class Participant
  attr_accessor :hand, :deck

  CARD_STRINGS = { 2 => 'a ' + '2'.red,
                   3 => 'a ' + '3'.red,
                   4 => 'a ' + '4'.red,
                   5 => 'a ' + '5'.red,
                   6 => 'a ' + '6'.red,
                   7 => 'a ' + '7'.red,
                   8 => 'an ' + '8'.red,
                   9 => 'a ' + '9'.red,
                   10 => 'a ' + '10'.red,
                   'J' => 'a ' + 'jack'.red,
                   'Q' => 'a ' + 'queen'.red,
                   'K' => 'a ' + 'king'.red,
                   'A' => 'an ' + 'ace'.red }

  def initialize(deck)
    @hand = []
    @deck = deck
  end

  def hit
    hand << deck.cards.pop
  end

  def total
    values = hand.map(&:value)
    if values.sum <= 11 && values.include?(1)
      values << 10
    end
    values.sum
  end

  def busted?
    total > 21
  end

  def show_cards
    cards = hand.map(&:rank)
    joinand(stringify_cards(cards))
  end

  private

  def stringify_cards(cards)
    cards.map { |card| CARD_STRINGS[card] }
  end

  def joinand(array)
    case array.length
    when 1
      array[0]
    when 2
      "#{array[0]} and #{array[1]}"
    else
      array[-1] = "and #{array.last}"
      array.join(', ')
    end
  end
end

class Player < Participant
end

class Dealer < Participant
  def show_one_card
    CARD_STRINGS[hand[0].rank]
  end

  def hit
    puts "The dealer hits!"
    super
  end
end

class Deck
  attr_accessor :cards

  def initialize
    @cards = create_deck
  end

  def reset
    @cards = create_deck
  end

  def deal
    cards.pop(2)
  end

  private

  def number_cards
    deck = []
    (2..10).each do |num|
      4.times do
        deck << Card.new(num)
      end
    end
    deck
  end

  def face_cards
    deck = []
    %w(J Q K A).each do |letter|
      4.times do
        deck << Card.new(letter)
      end
    end
    deck
  end

  def create_deck
    deck = []
    deck += number_cards
    deck += face_cards
    deck.shuffle
  end
end

class Card
  attr_reader :rank, :value

  def initialize(rank)
    @rank = rank
    @value = card_value
  end

  private

  def card_value
    case rank
    when (2..10)
      rank
    when /[JQK]/
      10
    else
      1
    end
  end
end

class Game
  def initialize
    @deck = Deck.new
    @player = Player.new(deck)
    @dealer = Dealer.new(deck)
  end

  def start
    display_welcome_message
    loop do
      reset
      deal_cards
      play_round
      show_result
      break unless play_again?
    end
    display_goodbye_message
  end

  private

  attr_accessor :deck, :player, :dealer

  MAX_VALUE = 21
  MIN_TO_STAY = 17

  def reset
    deck.reset
    player.hand = []
    dealer.hand = []
  end

  def play_again?
    answer = ''
    loop do
      puts "Would you like to play again? (y/n)"
      answer = gets.chomp.downcase
      break if %w(y n).include?(answer)
      puts "Sorry, you must input y or n."
    end
    answer == 'y'
  end

  def play_round
    player_turn
    dealer_turn unless player.busted?
  end

  def clear
    system 'clear'
  end

  def display_welcome_message
    clear
    puts "Welcome to 21!"
    puts "Whoever is closest to 21 without going over wins."
    puts "Hit to get another card, stay to keep the cards you have."
    puts "Press enter to continue"
    gets.chomp
  end

  def display_goodbye_message
    puts "Thanks for playing 21!"
  end

  def result
    return 'The dealer busted. You won!' if dealer.busted?
    return 'You busted. The dealer won!' if player.busted?
    return 'You won!' if player.total > dealer.total
    return 'The dealer won!' if player.total < dealer.total
    "It's a tie."
  end

  def show_result
    clear
    show_all_cards
    puts result
  end

  def dealer_turn
    show_dealer_cards
    sleep 2
    while dealer.total < MIN_TO_STAY
      dealer.hit
      sleep 1
      show_dealer_cards
      sleep 2
    end
  end

  def hit_or_stay?
    answer = ''
    loop do
      puts "Hit or stay? (h/s)"
      answer = gets.chomp.downcase
      break if %w(h s).include?(answer)
      puts "Sorry, you must enter h or s."
    end
    answer
  end

  def player_turn
    loop do
      clear
      show_cards_one_hidden
      break if player.total >= MAX_VALUE
      choice = hit_or_stay?
      break if choice == 's'
      player.hit
    end
  end

  def deal_cards
    player.hand += deck.deal
    dealer.hand += deck.deal
  end

  def show_player_cards
    puts "You have #{player.show_cards} for a total of " \
         + player.total.to_s.green + '.'
  end

  def show_one_dealer_card
    puts "The dealer has #{dealer.show_one_card} and another card."
  end

  def show_dealer_cards
    puts "The dealer has #{dealer.show_cards} for a total of " \
         + dealer.total.to_s.green + '.'
  end

  def show_cards_one_hidden
    show_player_cards
    show_one_dealer_card
  end

  def show_all_cards
    show_player_cards
    show_dealer_cards
  end
end

Game.new.start
