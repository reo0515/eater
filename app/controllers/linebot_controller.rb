class LinebotController < ApplicationController
  require 'line/bot'
  protect_from_forgery except: :callback

  def callback
    body = request.body.read
    events = client.parse_events_from(body)

    events.each { |event|
      message = Services::LineBot::BuildMessageService.new(event).invoke.result
      # client.reply_message(event['replyToken'], message)
    }

    head :ok
  end

  private

  def client
    Line::Bot::Client.new { |config|
      config.channel_secret = ENV['LINE_CHANNEL_SECRET']
      config.channel_token = ENV['LINE_CHANNEL_TOKEN']
    }
  end

end