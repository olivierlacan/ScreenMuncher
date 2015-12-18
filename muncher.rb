Bundler.require

require "ostruct"
require "net/http"

class ScreenMuncher
  Domain = "http://www.legendmicro.com/store"

  Manufacturers = OpenStruct.new(samsung: 39)

  def run
    # get the HTML from the website
    uri  = URI("#{Domain}/594_30in-and-Up-LCD.lmcp?page=1&Sortby=1&mfg_ID=#{Manufacturers.samsung}")
    body = Net::HTTP.get(uri)

    # parse it and use CSS selectors to find all rows the big table
    document = Nokogiri::HTML(body)
    tvs = document.css("#Table1 center font table tr")

    page_count = document.css("#Table3 ~ font").first.text.split("\r").first.sub("Page", "").lstrip.split(" of ").last.to_i

    tv_count = 0

    (1..page_count).to_a.each do |page|
      uri  = URI("#{Domain}/594_30in-and-Up-LCD.lmcp?page=#{page}&Sortby=1&mfg_ID=#{Manufacturers.samsung}")
      body = Net::HTTP.get(uri)

      # parse it and use CSS selectors to find all rows the big table
      document = Nokogiri::HTML(body)
      tvs = document.css("#Table1 center font table tr")

      # print each TV name and specs
      tvs.each do |tv|
        raw_info = tv.css('td')[1]
        relative_path = raw_info.css('a').first.attributes["href"].value
        tv_url = "#{Domain}/#{relative_path}"
        info = raw_info.text.strip.split("\r\n\t\t\t\t\t\t\t")
        name = info[0]
        specs = info[1]

        next if sucks?(name, specs)

        tv_count += 1

        uri  = URI(tv_url)
        body = Net::HTTP.get(uri)
        document = Nokogiri::HTML(body)
        detailed_specs = document.css("#table2")

        # Regex to extract dimensions: http://www.rubular.com/r/y3xCTVoZ9x
        # /(\d*.\d*)\\"\sx\s(\d*.\d*)\\"\sx\s(\d*.\d*)\\"/
        dimensions = detailed_specs.text.split("Dimensions:").last.split("\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t\t").first.lstrip.sub("\t\t\t\t\t\t\t\t\t\t\t\t", "")

        puts cleaned_name(name)
        puts specs.lstrip
        puts tv_url
        # puts dimensions
        puts "\n"
      end
    end
  end

  private

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

  def cleaned_name(name)
    name.sub("Monitor", "")
      .sub("Display", "")
      .sub("Samsung", "")
      .sub("HDTV", "")
      .sub(/(\d{2})in/, '\1"')
      .lstrip
  end

  def extract_thickness(dimensions)
    dimensions.split(" x ").last.to_f
  end
end

ScreenMuncher.new.run
