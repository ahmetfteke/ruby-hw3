require_relative 'APIProxy.rb'

class UserDataProxy < APIProxy
	def initialize(player)
		@player = player
	end
	def setPlayer
		open_url("https://randomuser.me/api/?inc=name&nat=usa")
		parse_url
	end
	def handle_parse
		@player.name_surname = @json_obj["results"][0]["name"]["first"] + " " +  @json_obj["results"][0]["name"]["last"]
	end
end



