class GoogleMapClient

    RADIUS = 1000

    def initialize(params = {})
      @conn = Faraday::Connection.new(url: Settings.google_map.url) do |builder|
        builder.response :logger
        builder.adapter  Faraday.default_adapter
      end
      @params = params
    end

    def fetch_nearby_places(lat, lon, keyword = nil)
      @params = {
        key: ENV['GOOGLE_MAPS_API_KEY'],
        location: lat + ',' + lon,
        keyword: keyword,
        radius: RADIUS,
        language: :ja
      }
      res = @conn.get('/maps/api/place/nearbysearch/json', @params)
      body = JSON.parse(res.body)
    end

end
