module Services
  module LineBot
    class BuildMessageService < Services::Base
      attr_reader :result

      def initialize(event)
        @event = event
      end

      def execute
        @result = build_message
      end

      private

      def build_message
        line_message = @event.message.symbolize_keys
        case line_message[:type]
        when 'location'
          sauna_service = Services::LineBot::SaunaService.new(line_message[:latitude], line_message[:longitude])
          sauna_service.invoke.result
        end
      end

    end
  end
end
