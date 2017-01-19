require_relative 'Card.rb'

class Player
	attr_accessor :name_surname, :cards, :bankroll, :last_amount_played, :play_style, :play_proc, :win, :lost, :fold, :played, :odd_to_win 
	def initialize
		@cards = Array.new
		@odd_to_win = 0.5
	end
end
