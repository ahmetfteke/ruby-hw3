	require_relative 'Database.rb'

class Table
  include Enumerable
	attr_accessor :players, :database, :fold_user_names, :dealer_index, :main_user_index, :number_of_players
	def initialize(number_of_players, main_user)
		@players = []
		@fold_user_names = []
		if number_of_players < 2 or number_of_players > 8
			abort "Minumum players should be between 2 and 8"
		end
		@number_of_players = number_of_players
		@database = Database.new(self, main_user, number_of_players)
		@database.set_players
		@dealer_index = rand(@players.length)
		@main_user_index = 0

	end
	def each_play(proc, table, money_on_the_table, current_deal, number_of_players_in_game)
		recent_deal = current_deal
		for i in @dealer_index..@number_of_players-1
			# if this user isn't in fold users
			if not @fold_user_names.include? @players[i]
				played_value = proc.call(i, @players, @main_user_index, current_deal)
				# if player call update current deal
				if not played_value.equal? 0
					@players[i].bankroll -= played_value
					current_deal = played_value
				# user fold
				else
					number_of_players_in_game -= 1
					@fold_user_names << @players[i]
				end
				money_on_the_table += current_deal
			end
		end
		for i in 0..@dealer_index-1
			# if this user isn't in fold users
			if not fold_user_names.include? @players[i]
				played_value = proc.call(i, @players, @main_user_index, current_deal)
				# if player  call update current deal
				if not played_value.equal? 0
					@players[i].bankroll -= played_value
					current_deal = played_value
				# user fold
				else
					number_of_players_in_game -= 1
					@fold_user_names << @players[i]
				end
				money_on_the_table += current_deal
			end
		end
		if not current_deal.eql? recent_deal
			for i in @dealer_index..@players.length-1
				if not fold_user_names.include? @players[i] and not i == @main_user_index
					played_value = proc.call(i, @players, @main_user_index, current_deal - recent_deal)
					# if player  call update current deal
					if not played_value.equal? 0
						@players[i].bankroll -= played_value
					# user fold
					else
						number_of_players_in_game -= 1
						@fold_user_names << @players[i]
					end
					money_on_the_table += played_value
				end
			end
		end
		return money_on_the_table, number_of_players_in_game, current_deal
	end
	def each_odds(proc, table, odd_proxy, board_cards, number_of_players_in_game)
		for i in @dealer_index..@number_of_players-1
			# if this user isn't in fold users
			if not @fold_user_names.include? @players[i]
				@players[i].odd_to_win = proc.call(i, @players, @main_user_index, @number_of_players, board_cards, odd_proxy)
			end
		end
		for i in 0..@dealer_index-1
			# if this user isn't in fold users
			if not @fold_user_names.include? @players[i]
				@players[i].odd_to_win = proc.call(i, @players, @main_user_index, @number_of_players, board_cards, odd_proxy)
			end
		end
		table
	end
end