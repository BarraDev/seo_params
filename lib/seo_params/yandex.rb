# -*- encoding: utf-8 -*-
require 'nokogiri'
require 'open-uri'

module SeoParams

  class Yandex

    def initialize(url)
      url.match(/^(https?:\/\/)/) ? @url = url : @url = 'http://' + url
      @host = URI(@url).host
    end


    def tic
      query = Nokogiri::XML(open("http://bar-navig.yandex.ru/u?ver=2&show=32&url=#{@url}"))
      tic = query.xpath('//@value')
      tic.to_s.to_i
    end
    
    def yandex_catalog
      query = Nokogiri::XML(open("http://bar-navig.yandex.ru/u?ver=2&show=32&url=#{@url}"))
      yaca = query.xpath('//@title')
      yaca.to_s.empty? ? false : true
    end
    
    def yandex_rang
      query = Nokogiri::XML(open("http://bar-navig.yandex.ru/u?ver=2&show=32&url=#{@url}"))
      rang = query.xpath('//@rang')
      rang.to_s.to_i
    end
    
    def cy
      query = Nokogiri::XML(open("http://bar-navig.yandex.ru/u?ver=2&show=32&url=#{@url}"))
      {tic: query.xpath('//@value').to_s.to_i, yaca: query.xpath('//@url').to_s.empty? ? false : true, rang: query.xpath('//@rang').to_s.to_i}
    end

    def yandex_pages
      pages = ask_yandex(@url)
      (pages.is_a? String) ? (@url = pages; pages = ask_yandex(pages); ) : pages
      pages
    end

    def yandex_position(user, key, lr, keywords, num)

      uri = URI.parse "http://xmlsearch.yandex.ru/xmlsearch?user=#{user}&key=#{key}&lr=#{lr}"

      h = Hash.new

      EventMachine.synchrony do
        EM::Synchrony::FiberIterator.new(keywords, keywords.size).each do |keyword|
          request = EventMachine::HttpRequest.new(uri)
          response = request.post(:body => xml_request(keyword, num))

          result = parse_results(response)

          (result.is_a? Hash) ? (h.merge! result) : (h[keyword] = result)

        end

        EventMachine.stop
      end

      h

    end


    private
      def ask_yandex(url)

        doc = Nokogiri::HTML(open("http://webmaster.yandex.ru/check.xml?hostname=#{url}"))

        if doc.css('div.error-message').length > 0
          if doc.css('div.error-message').children()[0].text().strip == "Сайт не проіндексовано."
            inder = 0
          else
            index = doc.css('div.error-message').children().children()[1].text()[0..-3].lstrip
          end
        else

          index = doc.css('div.header div').text()[/\d+/].to_i

        end

        index
      end

      def xml_request keyword, num
        "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
          <request>
            <query>#{keyword}</query>
            <groupings>
              <groupby attr=\"d\" mode=\"deep\" groups-on-page=\"#{num}\"  docs-in-group=\"1\" />
            </groupings>
          </request>"
      end

      def parse_results response
        h_err = Hash.new
        pos = 0
        i = 1
        doc = Nokogiri::XML(response.response)

        if doc.xpath('//error')
          doc.xpath("//error").map do |err|
            h_err["error_code"] = err['code']
            h_err["error_message"] = err.text()
          end
        end


        doc.xpath('//url').each do |link|
          if link.to_s[/#{Regexp.escape(@host)}/]
            pos = i
            break
          else
            i = i + 1
          end
        end


        (h_err.length != 0) ? h_err : pos

      end
  end

end
