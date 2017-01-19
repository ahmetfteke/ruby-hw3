require_relative 'APIProxy.rb'

class PokerOddsProxy < APIProxy
	def initialize
	end
	def handle_parse
		if @url_success
			begin
				@json_obj = JSON.parse(@object.read)
				odd = @json_obj["odds"]
			rescue
				puts "\tJSON Failed"
				odd = rand(1..100) / 100.0
			end
		else
			odd = rand(1..100) / 100.0
		end
		odd
	end
end