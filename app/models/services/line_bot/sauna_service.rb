module Services
  module LineBot
    class SaunaService < Services::Base
      require 'open-uri'
      attr_reader :result

      MAX_NUMBER = 3

      def initialize(lat, lon)
        @lat = lat.to_s
        @lon = lon.to_s
      end

      def execute
        @result = create_reply_meessage
      end

      private

      def create_reply_meessage
        docs = self.scrape_saunaikitai
        reply_messages = []

        if docs.present?
          return self.exsit_document_pattern(reply_messages, docs)
        else
          reply_messages << { type: :text, text: '半径1キロメートル圏内にサウナが見つかりませんでした。'}
          return reply_messages
        end
      end

      # TODO: 住所を良い感じに分割してくれるライブラリを入れて東京以外でも検索出来るようにする。
      def scrape_saunaikitai
        saunas = fetch_nearby_saunas['results']
        docs = []
        if saunas.present?
          saunas.each do |sauna|
            target_url = Settings.saunaikitai.url + '/search?keyword='
            params = URI.encode_www_form_component("#{sauna['name']} 東京")
            html = URI.open(target_url + params).read

            docs << Nokogiri::HTML.parse(html)
          end
        end

        docs
      end

      def exsit_document_pattern(ary, docs)
        docs.each do |doc|
          doc.css('a').each do |anchor|
            break if ary.count == MAX_NUMBER
            break if anchor[:href].nil?

            if anchor[:href].match("https://sauna-ikitai.com/saunas/#{/\d+/}")
              ary << { type: :text, text: anchor[:href] }
              break
            end
          end
        end

        ary
      end

      def fetch_nearby_saunas
        GoogleMapClient.new.fetch_nearby_places(@lat, @lon, 'サウナ')
      end

    end
  end
end
