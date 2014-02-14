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
    	user = Random.rand(1...1000)
      $clients[user] = {sock: ws}
      ws.send "id:#{user}"
    end

    ws.onclose do
      ws.send "Closed."
      $clients.delete ws
    end

    ws.onmessage do |msg|
      puts "Received Message: #{msg}"
      splitMsg = msg.split(':')
      command = splitMsg[0]
      message = splitMsg[1]
      user_id = splitMsg[2]
      case command
        when 'join'
          $clients[user_id.to_i][:pair] = message.to_i
          $clients[message.to_i][:pair] = user_id.to_i
          puts $clients
        when 'chat'
          send($clients[user_id.to_i][:pair],'message: receved ' + message + ' from #{user_id}')
          send(user_id,'sent: '+ message)
        when 'move'
          send($clients[user_id.to_i][:pair],'move:'+ message)
      end

    end

    def send(target, text)
     $clients[target.to_i][:sock].send text
    end
  end


  App.run! :port => 3000, :bind => "0.0.0.0"
end

