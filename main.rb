require_relative 'Player.rb'
require_relative 'Table.rb'
require_relative 'Deck.rb'
require_relative 'Game.rb'

def main()
	main_user = Player.new
	puts "Welcome to Texas Hold'em Poker!"
	print "Enter your name: "
	main_user = Player.new
	main_user.name_surname = gets.chomp
	puts "-----------"
	print "Enter starting chip amount: "
	chip_amount = gets.chomp.to_i
	puts "-----------"
	table = Table.new(3, main_user)
	game = Game.new(table)
	game.play(chip_amount)
end
main
