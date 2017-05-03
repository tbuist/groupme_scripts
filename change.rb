#!/usr/bin/ruby

require 'optparse'
require 'json'
require 'httparty'
require 'logger'

$logger = Logger.new('log.log', 5, 1024000)
$logger.level = Logger::INFO
$logger.datetime_format = '%Y-%m-%d %H:%M:%S'

class Bodypart
	attr_accessor :part, :plural
	def initialize(part, plural)
		@part = part
		@plural = plural
	end
end

class Chef
	attr_accessor :config, :urls, :names, :adjectives, :bodyparts
	def initialize()
		@config = {}
		File.open("config/config.txt", "r").each do |line|
			@config[:"#{line.split("=")[0]}"] = line.split("=")[1].delete("\n")
		end
		@config[:base_url] = "https://api.groupme.com/v3/"
		@config.each do |k,v|
			instance_variable_set(:"@#{k}", v)
		end

		@urls = []
		File.open("config/urls.list", "r").each do |line|
			@urls.push(line.delete("\n"))
		end

		@names = []
		File.open("config/names.list", "r").each do |line|
			@names.push(line.delete("\n"))
		end

		@adjectives = []
		File.open("config/adjectives.list", "r").each do |line|
			@adjectives.push(line.delete("\n"))
		end

		# body part, plural(t/f)
		@bodyparts = []
		File.open("config/bodyparts.list", "r").each do |line|
			part = line.split(",")[0]
			plural = true?(line.split(",")[1].delete("\n"))
			body = Bodypart.new(part, plural)
			@bodyparts.push(body)
		end
	end
	def serve(action)
		base_url = "https://api.groupme.com/v3/"
		case action
		when :rand_avatar
			url = base_url + "groups/#{config[:group_id]}/update?token=#{config[:token]}"
			body = { :image_url => urls[Random.rand(urls.length())] }.to_json
			header = { 'Content-Type' => 'application/json' }
			#send post request
			begin
				$logger.info("pushing random avatar request")
				result = HTTParty.post(url, :body => body, :headers => header)
			rescue
				$logger.error("error in serve::rand_avatar - #{result}")
			end
		when :rand_name
			new_name = @names[Random.rand(@names.length)]
			new_adj = @adjectives[Random.rand(@adjectives.length)]
			new_bodypart = @bodyparts[Random.rand(@bodyparts.length)]
			conj = ""
			if not new_bodypart.plural
				if new_adj.downcase.start_with?("a","e","i","o","u")
					conj = "an "
				else
					conj = "a "
				end
			end
			new_group_name = "#{new_name} has #{conj}#{new_adj} #{new_bodypart.part}"
			
			url = base_url + "groups/#{config[:group_id]}/update?token=#{config[:token]}"
			body = { :name => new_group_name }.to_json
			header = { 'Content-Type' => 'application/json' }
			#send post request
			begin
				$logger.info("push new groupname #{new_group_name}")
				result = HTTParty.post(url, :body => body, :headers => header)
			rescue
				$logger.error("error in serve::rand_name - #{result}")
			end
		end
	end
	def get_group_info()
		url = @config[:base_url] + "groups/#{@config[:group_id]}?token=#{@config[:token]}"
		begin
			response = HTTParty.get(url).parsed_response
		rescue
			$logger.error("error in get_group_info - #{response}")
		end
	end
	def true?(obj)
		obj.to_s == "true"
	end
end

options = {:random => true, :specific => "", :actions => []}
OptionParser.new do |opts|
	opts.banner = "Usage: ruby avatar.rb [option]"

	opts.on("-r", "--random", "Pic random image from config/urls.list") do |r|
		options[:random] = r
		options[:actions].push(:ra)
	end

	opts.on("-s", "--specific IMAGE_URL", "Repeatedly set avater to IMAGE_URL") do |s|
		options[:specific] = s.delete("\n")
		options[:random] = false
		options[:actions].push(:sa)
	end

	opts.on("-g", "--groupname", "Generate and use a random groupname") do |g|
		options[:actions].push(:rn)
	end
end.parse!

if options[:actions].include?(:ra) and options[:actions].include?(:sa)
	$logger.error("can't have both random and specific avatar")
	exit
end

chef = Chef.new

if options[:actions].include?(:ra)
	chef.serve(:rand_avatar)
end
if options[:actions].include?(:rn)
	chef.serve(:rand_name)
end
