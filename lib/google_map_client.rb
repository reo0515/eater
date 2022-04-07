class GoogleMapClient

    MIN_RADIUS = 1000

    def initialize(params = {})
      @conn = Faraday::Connection.new(url: Settings.google_map.url)
      @params = params
    end

    def fetch_nearby_places(lat, lon, keyword = nil, radius = MIN_RADIUS)
      @params[:key] = ENV['GOOGLE_MAPS_API_KEY']
      @params[:location] = lat + ',' + lon
      @params[:keyword] = keyword
      @params[:radius] = radius

      res = @conn.get('/maps/api/place/nearbysearch/json', @params)
      body = JSON.parse(res.body)
    end

end
