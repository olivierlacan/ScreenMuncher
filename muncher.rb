Bundler.require

require "net/http"

Manufacturers = {
  samsung: 39
}

def sucks?(name, specs)
  return true if name.include?("C-Grade")
  return true if !specs.include?("HDMI")

  !specs.include?("1920x1080") and
  !specs.include?("1080p") and
  !specs.include?("450cd/m2") and
  !specs.include?("300cd/m2") and
  !specs.include?("700cd/m2") and
  !specs.include?("350cd/m2")
end

3.times do |page|
  page_number = page + 1

  # get the HTML from the website
  uri  = URI("http://www.legendmicro.com/store/594_30in-and-Up-LCD.lmcp?page=#{page_number}&Sortby=1&mfg_ID=#{Manufacturers[:samsung]}")
  body = Net::HTTP.get(uri)

  # parse it and use CSS selectors to find all rows the big table
  document = Nokogiri::HTML(body)
  tvs = document.css("#Table1 center font table tr")


  # print each TV name and specs
  tvs.each do |tv|
    info = tv.css('td')[1].text.strip.split("\r\n\t\t\t\t\t\t\t")
    name = info[0]
    specs = info[1]

    next if sucks?(name, specs)

    puts "#{name} - #{specs}"
  end
end

