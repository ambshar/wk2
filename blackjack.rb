require 'pry'
class Card

  attr_accessor :suit, :value
  def initialize(s,v)
    @suit = s
    @value = v
  end

  def to_s
    "#{value} of #{find_suit}"
  end

  def find_suit
    case suit
      when 'H' then 'Hearts'
      when 'D' then 'Diamonds'
      when 'S' then 'Spades'
      when 'C' then 'Clubs'
    end
  end

  def face_value
    if value == 'A'
      #numeric_value = 11
      11
     elsif value.to_i == 0
       #numeric_value = 10
       10
     else
       #numeric_value = value.to_i
       value.to_i
    end
    #numeric_value 
  end

end

class Deck
  attr_accessor :cards
  def initialize(num_decks = 1)
    @cards = []
    ['H', 'D', 'S', 'C'].each do |s|
      ['2','3','4','5','6','7','8','9','10','J','Q','K','A'].each do |v|
        @cards << Card.new(s,v)
      end
    end
    @cards = @cards*num_decks
    
    scramble
    
  end

  def scramble
    cards.shuffle!
    
  end

  def deal
    cards.pop
  end

  def size
    cards.size
  end

end

module Hand
  def show_hand
    puts "---#{name}'s Hand---"
    cards.each do |card|
      puts "=>  #{card}"
    end
    puts "Total = #{total}"
  end

  def total
    values = cards.map{|card| card.value}

    total = 0
    values.each do |v|
      if v == 'A'
        total +=11
      else
        total += (v.to_i == 0 ? 10 : v.to_i)
      end
     
    end

    values.select{|v| v == 'A'}.count.times do
      break if total <= 21
      total -= 10
    end

    total
  end
  
  def add_card(card)    
    cards << card
  end

  def is_busted?
    total > Blackjack::BLACKJACK_AMOUNT
  end

  

end

class Player
  include Hand
  attr_accessor :cards, :name
  def initialize()
    @cards = []
    @name = nil
    @hit_or_stay = nil
  end

  def show_flop
    show_hand
  end

  

  
end


class Dealer 
  include Hand
  attr_accessor :cards, :name
  def initialize
    @name = "Dealer"
    @cards = []

  end

  def show_flop
    puts "---#{name}'s Hand---"
    puts "1st card is hidden"
    puts "2nd card is #{cards[1]}"

  end

end

class Blackjack
  attr_accessor :player, :dealer, :deck

BLACKJACK_AMOUNT = 21
DEALER_HIT_MIN = 17

  def initialize
    @player = Player.new
    
    @dealer = Dealer.new
    @deck = Deck.new
  end

  def set_player_name
    
    
    puts "What's your name"
    player.name = gets.chomp
    
  end

  

  def deal_cards #first time deal cards to players and dealer
    player.add_card(deck.deal)
    dealer.add_card(deck.deal)
    player.add_card(deck.deal)
    dealer.add_card(deck.deal)
  end

  def show_flop
    player.show_flop
    puts 
    dealer.show_flop
  end
  def blackjack_or_bust?(player_or_dealer)
    if player_or_dealer.total == BLACKJACK_AMOUNT
      if player_or_dealer.is_a?(Dealer)

        puts "Sorry Dealer hit blackjack.  #{player.name} loses"
      else
        puts "Congratulations, you hit Blackjack #{player.name}"
      end
      play_again?
    elsif player_or_dealer.is_busted?
      if player_or_dealer.is_a?(Dealer) 
        puts "Congratulations dealer busted.  #{player.name} wins"
      else
        puts "Sorry, #{player.name} busted."
      end
      play_again?
    end
  end
  
  def player_turn
    puts "#{player.name}'s turn"

    blackjack_or_bust?(player)
    while !player.is_busted?
      puts "Do you want to hit or stay? h to hit, s to stay"
      hit_or_stay = gets.chomp.downcase
        if !['h', 's'].include?(hit_or_stay)
          puts "Only h or s please "
          break
        end
      if hit_or_stay == 's'
        puts "#{player.name} stays"
        break
      end  
      
      new_card = deck.deal
      puts "Card for #{player.name}: #{new_card}"
      player.add_card(new_card)
      puts "Total becomes: #{player.total}"
      blackjack_or_bust?(player)
    end
    puts "#{player.name} stays at #{player.total}"
  end

  def dealer_turn
    puts "#{dealer.name}'s turn"
    dealer.show_hand    
    blackjack_or_bust?(dealer)

    while dealer.total < DEALER_HIT_MIN
      
        new_card = deck.deal
        puts "Card for #{dealer.name}: #{new_card}"
        dealer.add_card(new_card)
        puts "Dealer total becomes: #{dealer.total}"
        blackjack_or_bust?(dealer)
      
    end

    puts "Dealer stays at #{dealer.total}"

  end

  def who_won?(player, dealer)
    if player.total > dealer.total
      puts "Congratulations #{player.name} won"

    elsif player.total == dealer.total
      puts "It\'s a push"
    else
      puts "Sorry #{player.name} loses"
    end

    play_again?

  end

  def play_again?
    puts""
    puts "Would you like to play again 1 - yes, 2 - no, exit"
    if gets.chomp == '1'
      puts "Starting new game..."
      puts ""
      deck = Deck.new
      player.cards = []
      dealer.cards = []
      run
    else
      puts "Goodbye"
      exit
    end
  end
  def run
    set_player_name if player.name == nil
    deal_cards
    
    show_flop
    
    player_turn
    
    dealer_turn
    who_won?(player, dealer)
  end

end



current_game = Blackjack.new

current_game.run
