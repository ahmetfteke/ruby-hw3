require 'json'
require 'open-uri'
require 'openssl'
OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

class APIProxy
	attr_accessor :url_success
	def initialize
		raise NoMethodError
	end
	def open_url(url)
		begin 
			@object = open(url)
			@url_success = true
		rescue OpenURI::HTTPError => error
			puts "\tAPI failed."
			response = error.io
			response.status
			response.string
			@url_success = false
		end
	end
	def parse_url
		@json_obj = JSON.parse(@object.read)
	end
	def handle_parse
		raise NoMethodError
	end
end
