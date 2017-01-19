require_relative 'PokerOddsProxy.rb'

class Game
	def initialize(table)
		@table = table
		@main_user_index = 0
		@number_of_players_in_game = @table.players.length

		@money_on_the_table = 0
		@current_deal = 0

		@odd_proxy = PokerOddsProxy.new
	end
	def play(chip_amount)
		@chip_amount = chip_amount
		@current_deal = @chip_amount / 20
		create_procs
		set_bankroll(chip_amount)
		want_play = "y"
		while want_play == "y"
			@board_cards = Array.new
			@deck = Deck.new.deck 
			@deck.shuffle!
			deal_cards
			play_round("First round!", 3)
			get_odds
			play_round("Second round!", 1)
			get_odds
			play_round("Third round!", 1)
			get_odds
			play_round("Fourth round!", 0)
			who_won
			update_settings
			puts "Do you want to play another game: y or n"
			want_play = gets.chomp

		end
	end
	def play_round(text, how_many_cards_open)
		puts text
		seperator
		if @number_of_players_in_game == 1
			return
		end
		@money_on_the_table, @number_of_players_in_game, @current_deal = @table.each_play(@general_play, @table, @money_on_the_table, @current_deal, @number_of_players_in_game)
		puts "Money on the table: #{@money_on_the_table}"
		seperator

		puts "Players in the game: #{@number_of_players_in_game}"
		seperator

		(0..how_many_cards_open-1).each { @board_cards << @deck.shift }

		print_cars
	end
	def get_odds
		if @number_of_players_in_game == 1
			return
		end
		@table = @table.each_odds(@get_odds, @table, @odd_proxy, @board_cards, @number_of_players_in_game)
	end
	def who_won

		winner_index = 0

		@table.players.each_with_index{ |val, index|
			@table.players[index].played += 1
			if not @table.fold_user_names.include? @table.players[index].name_surname 
				if @table.fold_user_names.include? @table.players[winner_index].name_surname
					winner_index = index
				elsif  @table.players[index].odd_to_win > @table.players[winner_index].odd_to_win 
					winner_index = index
				else
					@table.players[index].lost += 1
				end
			else
				@table.players[index].fold += 1
			end
		}
		@table.players[winner_index].win += 1
		@table.players[winner_index].bankroll += @money_on_the_table
		puts "Winner: #{@table.players[winner_index].name_surname}"

	end
	def update_settings
		db = Database.new(@table, @table.players[0], @table.players.length)
		db.update
		@table.dealer_index += 1 
		@table.dealer_index = @table.dealer_index % @table.players.length
		@table.fold_user_names = []
		@money_on_the_table = 0
		@number_of_players_in_game = @table.players.length
		@table.players.each{ |p|
			p.odd_to_win = 0.5
		}
		@current_deal = @chip_amount / 20
	end
	def create_procs
		@general_play = Proc.new {|index, players, main_user_index, current_deal| 
			if players[index].name_surname.equal? players[main_user_index].name_surname
				print "\tDo you call? Press y or n: "
				answer = gets.chomp
				if answer == "y" and players[index].bankroll >= current_deal
					print "\tDo you want to Raise? Press y or n: "
					answer = gets.chomp
					if answer == "y"
						print "\tEnter new amount of deal: "
						answer = gets.chomp.to_i
						if players[index].bankroll >= answer
							current_deal = answer
							puts "#{players[index].name_surname} (Raise) : #{current_deal} (Money: #{players[index].bankroll-current_deal})"
						elsif current_deal > answer
							puts "\tYou need to enter amount bigger than current deal."
							puts "#{players[index].name_surname} (Call) : #{current_deal} (Money: #{players[index].bankroll-current_deal})"
						else
							puts "\tYou don't have enough money to raise."
							puts "#{players[index].name_surname} (Call) : #{current_deal} (Money: #{players[index].bankroll-current_deal})"
						end
					else
						puts "#{players[index].name_surname} (Call) : #{current_deal} (Money: #{players[index].bankroll-current_deal})"
					end
				else
					puts "#{players[index].name_surname} (Fold) (Money: #{players[index].bankroll})"
					current_deal = 0
				end
			else
				if players[index].play_proc.call(players[index].odd_to_win, players[index].bankroll, current_deal)
					puts "#{players[index].name_surname} (Call) :#{current_deal} (Money: #{players[index].bankroll-current_deal})"
				else
					puts "#{players[index].name_surname} (Fold) (Money: #{players[index].bankroll})"
					current_deal = 0
				end
			end
			current_deal
		} 

		@get_odds = Proc.new {|index, players, main_user_index, number_of_players, board_cards, odd_proxy| 
			b_cards = ""
			board_cards.each { |c|  
				b_cards += c.to_s
			}
			url = "http://stevenamoore.me/projects/holdemapi?cards=%s%s&board=%s&num_players=%s" % [players[index].cards[0], players[index].cards[1], b_cards, number_of_players] 
			puts "\t#{url}"
			odd_proxy.open_url(url)
			odd = odd_proxy.handle_parse
			if players[index].name_surname.equal? players[main_user_index].name_surname
				puts "Your odd to win this round: #{odd}"
			else
				puts "#{players[index].name_surname} odd to win this round: #{odd}"
			end
			seperator
			odd
		}
	end
	def deal_cards
		puts "Our dealer is: #{@table.players[@table.dealer_index].name_surname}"
		seperator
		(@table.dealer_index..(@table.number_of_players)-1).each{ |i|
			@table.players[i].cards[0] = @deck.shift 
			@table.players[i].cards[1] = @deck.shift
		}
		(0..@table.dealer_index-1).each{|i|
			@table.players[i].cards[0] = @deck.shift 
			@table.players[i].cards[1] = @deck.shift
		}
		puts "Your cards: " + @table.players[@table.main_user_index].cards[0].to_s + " " + @table.players[@table.main_user_index].cards[1].to_s
		seperator
	end
	def set_bankroll(chip_amount)
		@table.players.each{|p|
			p.bankroll = chip_amount
		}
	end
	def print_cars
		print "Cards on the board: "
		@board_cards.each{ |c|
			print c.to_s + " "
		}
		puts ""
		seperator
	end
	def seperator
		puts "-----------"
	end
end