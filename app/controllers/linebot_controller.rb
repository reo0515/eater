class LinebotController < ApplicationController
  require 'line/bot'
  protect_from_forgery except: :callback
  # before_action :validate_signature, except: [:new, :create]

  # def validate_signature
  #   body = request.body.read
  #   signature = request.env['HTTP_X_LINE_SIGNATURE']
  #   unless client.validate_signature(body, signature)
  #     error 400 do 'Bad Request' end
  #   end
  # end

  def callback
    body = request.body.read
    events = client.parse_events_from(body)

    events.each { |event|
      case event
      when Line::Bot::Event::Message
        case event.type
        when Line::Bot::Event::MessageType::Text
          message = {
            type: 'text',
            text: response
          }
          client.reply_message(event['replyToken'], message)
        when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
          response = client.get_message_content(event.message['id'])
          tf = Tempfile.open("content")
          tf.write(response.body)
        end
      end
    }

    head :ok
  end

  private

  def client
    @client ||= Line::Bot::Client.new { |config|
      # ローカルで動かすだけならベタ打ちでもOK。
      config.channel_secret = "1657032274"
      config.channel_token = "05171c25ad73d5d11d87a36713033a31"
    }
  end

end