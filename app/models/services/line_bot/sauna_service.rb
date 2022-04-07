module Services
  module LineBot
    class SaunaService < Services::Base
      attr_reader :result

      def initialize(lat, lon)
        @lat = lat.to_s
        @lon = lon.to_s
      end

      def execute
        @result = pick_nearby_sauna
      end

      private

      def pick_nearby_sauna
        res = GoogleMapClient.new.fetch_nearby_places(@lat, @lon, 'サウナ')
        p res
      end

    end
  end
end
