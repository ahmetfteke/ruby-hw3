 require_relative 'UserDataProxy.rb'
require_relative 'Player.rb'
require 'json'

class Database
	def initialize(table, main_user, number_of_players)
		@table = table
		@number_of_players = number_of_players
		@player_files = []
		@main_user = main_user
	end
	def set_players
		# template method
		decide_player_numbers
		add_main_user
		read_players
		create_players
		set_procs
		print_players
	end
	def decide_player_numbers
		Dir.glob('Players/*.json').select{ |e| 
			File.file? e 
			@player_files << e
		}
		if @number_of_players > @player_files.length
			@how_many_should_read = @player_files.length
		else
			@how_many_should_read = @number_of_players
		end
	end
	def read_players
		#read users who in db
		(0..@how_many_should_read-2).each{|i|
			user = Player.new
			file = File.read(@player_files[i])
			json_obj = JSON.parse(file)
			user.play_style = json_obj["play style"]
			user.name_surname = json_obj["name surname"]
			user.win = json_obj["win"]
			user.lost = json_obj["lost"]
			user.fold = json_obj["fold"]
			user.played = json_obj["played"]
			@table.players << user
		}
	end`	
	def create_players
		#create a new player when needed
		need_more = @number_of_players - @player_files.length - 1
		(0..need_more).each{ |i|
			user = Player.new
			user.play_style = get_random_style
			user.win = 0
			user.lost = 0
			user.fold = 0
			user.played = 0
			udp = UserDataProxy.new(user)
			udp.setPlayer
			udp.handle_parse
			json_hash = Hash.new
			json_hash["name surname"] = user.name_surname
			json_hash["play style"] = user.play_style 
			json_hash["win"] = user.win 
			json_hash["lost"] = user.lost 
			json_hash["fold"] = user.fold 
			json_hash["played"] = user.played 
			File.open("Players/" + user.name_surname + ".json","w") do |f|
			  f.write(json_hash.to_json)
			end
			@table.players << user
		}
	end
	def add_main_user
		#if user exists

		if File.file? ("Players" + @main_user.name_surname)
			file = File.read("Players" + @main_user.name_surname)
			json_obj = JSON.parse(file)
			@main_user.play_style = json_obj["play style"]
			@main_user.name_surname = json_obj["name surname"]
			@main_user.win = json_obj["win"]
			@main_user.lost = json_obj["lost"]
			@main_user.fold = json_obj["fold"]
			@main_user.played = json_obj["played"]
			@table.players << @main_user
			@player_files.delete 'Players/#{@main_user.name_surname}.json'
		#if user doesn't exist
		else
			@main_user.win = 0
			@main_user.lost = 0
			@main_user.fold = 0
			@main_user.played = 0
			json_hash = Hash.new
			json_hash["name surname"] = @main_user.name_surname
			json_hash["play style"] = @main_user.play_style 
			json_hash["win"] = @main_user.win 
			json_hash["lost"] = @main_user.lost 
			json_hash["fold"] = @main_user.fold 
			json_hash["played"] = @main_user.played 
			File.open("Players/" + @main_user.name_surname + ".json","w") do |f|
			  f.write(json_hash.to_json)
			end
			@table.players << @main_user
		end

	end
	def get_random_style
		["loose_aggressive", "loose_passive", "tight_aggressive", "tight_passive"].sample
	end
	def print_players
		 c = 1
		@table.players.each{ |p|
			puts "#{c}. Player: #{p.name_surname}"
			if not p.name_surname.equal? @main_user.name_surname
				puts "   Playing Style:  #{p.play_style}"
			end
			c += 1
		}
		puts "-----------"
	end
	def set_procs
		@loose_aggressive = Proc.new{ |odd, bankroll, current_deal|
			should_play = false
			if odd.to_f > 0.1 and bankroll / 2 > current_deal
				should_play = true
			end 
			should_play
		}
		@loose_passive = Proc.new{ |odd, bankroll, current_deal|
			should_play = false
			if odd.to_f > 0.2 and bankroll / 2 > current_deal
				should_play = true
			end 
			should_play
		}
		@tight_aggressive = Proc.new{ |odd, bankroll, current_deal|
			should_play = false
			if odd.to_f > 0.1 and (bankroll / 4) > current_deal
				should_play = true
			end 
			should_play
		}
		@tight_passive = Proc.new{ |odd, bankroll, current_deal|
			should_play = false
			if odd.to_f > 0.2 and (bankroll / 4) > current_deal
				should_play = true
			end 
			should_play
		}
		@table.players.each{ |p|
			if p.play_style.eql? 	 "loose_aggressive"
				p.play_proc = @loose_aggressive
			elsif p.play_style.eql? "loose_passive"
				p.play_proc = @loose_passive
			elsif p.play_style.eql? "tight_aggressive"
				p.play_proc = @tight_aggressive
			elsif p.play_style.eql? "tight_passive"
				p.play_proc = @tight_passive
			end
		}

	end
	def update
		@table.players.each{ |user|
			json_hash = Hash.new
			json_hash["name surname"] = user.name_surname
			json_hash["play style"] = user.play_style 
			json_hash["win"] = user.win 
			json_hash["lost"] = user.lost 
			json_hash["fold"] = user.fold 
			json_hash["played"] = user.played 
			File.open("Players/" + user.name_surname + ".json","w") do |f|
			  f.write(json_hash.to_json)
			end
		}
	end
end