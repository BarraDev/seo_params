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
      index = @response.xpath("//div[@id='pg']")
      index.first.children.last.text.delete(",").to_i unless index.first.nil?
    end

  end

end
