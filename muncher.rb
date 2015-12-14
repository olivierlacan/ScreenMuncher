require 'nokogiri'
require 'net/http'
require 'pry'

Manufacturers = {
  samsung: 39
}

3.times do |page|
  page_number = page + 1

  # get the HTML from the website
  uri  = URI("http://www.legendmicro.com/store/594_30in-and-Up-LCD.lmcp?page=#{page_number}&Sortby=1&mfg_ID=#{Manufacturers[:samsung]}")
  body = Net::HTTP.get(uri)

  # parse it and use CSS selectors to find all links in list elements
  document = Nokogiri::HTML(body)
  tvs     = document.css("#Table1 center font table tr")


  # print each interesting looking link
  tvs.each do |tv|
    info = tv.css('td')[1].text.strip.split("\r\n\t\t\t\t\t\t\t")
    name = info[0]
    specs = info[1]

    puts "#{name} - #{specs}"
  end
end
