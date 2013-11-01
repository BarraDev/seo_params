# -*- encoding: utf-8 -*-
require 'nokogiri'
require 'open-uri'

module SeoParams

  class Yahoo

    def initialize(url)
      @url = url
      @response = Nokogiri::HTML(open("http://search.yahoo.com/search?p=site:#{url}"))
    end

    def yahoo_pages
      return @response.xpath("//div[@id='pg']").first.children.last.text.delete(",").to_i unless @response.xpath("//div[@id='pg']").first.nil?
      ''
    end

  end

end
