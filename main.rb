gem 'thin'
gem 'sinatra'
gem 'em-websocket'

# app.rb
require 'thin'
require 'sinatra/base'
require 'em-websocket'
require 'sinatra'


EventMachine.run do
	# Sinatra::Application.set :bind, "0.0.0.0"

  class App < Sinatra::Base
 	
    get '/' do
      erb :index
    end
  end

 $clients = []

  EM::WebSocket.start(:host => '0.0.0.0', :port => '3001') do |ws|
    ws.onopen do |handshake|
    	user = Random.rand(1...1000)
      $clients << {sock: ws, user: user}
      ws.send "id:#{user}"
    end

    ws.onclose do
      ws.send "Closed."
      $clients.delete ws
    end

    ws.onmessage do |msg|
      puts "Received Message: #{msg}"
      text = msg.split(',')[1]
      user = msg.split(',')[0].to_i
      friend = msg.split(',')[2].to_i
      $clients.each do |socket|
      	if socket[:user] == friend
         socket[:sock].send text
        end 
      end
    end
  end


  App.run! :port => 3000, :bind => "0.0.0.0"
end

