require 'json'
require 'net/http'
require 'uri'

# careful, apparently there's an api limit

data = {}
File.open("config/config.txt", "r").each do |line|
	data[line.split('=')[0]] => line.split('=')[1]
end

Dir.foreach("config/pics") do |pic|
	next if pic == '.' or pic == '..'

	uri = URI.parse(url)
	cont_type = "image/#{pic.split('.')[1]}"
	request = Net::HTTP::Post.new(uri)
	request.content_type = cont_type
	request["X-Access-Token"] = data['token']
	request.body = ""
	request.body << File.read("config/pics/" + pic)

	req_options = { use_ssl: uri.scheme == "https" }

	response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
		http.request(request) 
	end

	response = JSON.parse(response.body)['payload']
	
	open("config/urls.list", 'a+') { |f| f.puts(response['url']) }
end