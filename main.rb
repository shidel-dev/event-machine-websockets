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

    # configure do
    #   # See: http://www.sinatrarb.com/faq.html#sessions
    #   enable :sessions
    #   set :session_secret, ENV['SESSION_SECRET'] || 'this is a secret shhhhh'
    # end

    get '/' do
      erb :index
    end


  end

 $clients = {}

  EM::WebSocket.start(:host => '0.0.0.0', :port => '3001') do |ws|
    ws.onopen do |handshake|
    	user = Random.rand(1...1000).to_s
      $clients[user] = {sock: ws}
      ws.send "id:#{user}"
      puts user
    end

    ws.onclose do
      $clients.each_key do |client|
        if $clients[client][:sock] == ws
          $clients.delete(client)
        end
      end
    end

    ws.onmessage do |msg|
      puts "Received Message: #{msg}"
      splitMsg = msg.split(':')
      command = splitMsg[0]
      message = splitMsg[1]
      user_id = splitMsg[2]
      case command
        when 'join'
          $clients[user_id][:pair] = message
          $clients[message][:pair] = user_id
          send(message,"set:O")
          puts $clients
        when 'chat'
          send($clients[user_id][:pair],"message: #{user_id} =>  " + message )
          send(user_id,'message: you=>  '+ message)
        when 'move'
          send($clients[user_id][:pair],'move:'+ message)
        when 'alias'
         clone = $clients[message]
         $clients[user_id] = clone
         $clients.delete(message)
         puts $clients
      end

    end

    def send(target, text)
     $clients[target][:sock].send text
    end
  end


  App.run! :port => 3000, :bind => "0.0.0.0"
end

