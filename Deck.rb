require_relative 'Card.rb'

class Deck
	SUITS = ["d", "c", "h", "s"]
	NUMBERS = (2..14).to_a
	attr_accessor :deck 
	def initialize
		@deck = []
		SUITS.each do |suit|
			NUMBERS.each do |num|
				@deck << Card.new(suit, num)
			end
		end
		
	end

end
