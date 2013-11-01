# -*- encoding: utf-8 -*-
require 'nokogiri'
require 'open-uri'

module SeoParams

  class Bing

    def initialize(url)
      @url = url
      @response = Nokogiri::HTML(open("http://www.bing.com/search?q=site:#{url}"))
    end

    def bing_pages
      index = @response.xpath("//span[@id='count']")
      index.first.text.delete(",").to_i unless index.first.nil?
    end

  end

end
