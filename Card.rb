class Card
	attr_reader :suit, :number
	def initialize(suit, number)
		@suit = suit
		@number = number
	end

	def to_s
		Card.parse_card(@number) + @suit
	end

	def self.parse_card(number)
	  case number
		when 2..9 then number.to_s
		when 10 then "T"
		when 11 then "J"
		when 12 then "Q"
		when 13 then "K"
		when 14 then "A"
		end
	end
end