# Scraper class responsible for
# #scraping data from website
# #adding data to weather data table in db/weather.db
# DOES NOT CREATE OBJECTS

# Weather class responsible for
# #reifying database rows into weather daily objects
# #includes SQL methods for sorting / displaying data

class TempestryPattern::Scraper
  attr_accessor :zip, :year, :name, :description, :url, :next_day_url, :date, :location_name, :weather_station, :max_temp, :temp_units, :color
  @@all = []

  def initialize
    self.zip = TempestryPattern::CLI.zip
    self.year = TempestryPattern::CLI.year
    self.name = TempestryPattern::CLI.name
    self.description = TempestryPattern::CLI.description

    if @@all == []
      self.url = "https://www.almanac.com/weather/history/zipcode/#{zip}/#{year}-01-01"
    else
      self.url = TempestryPattern::Scraper.all.last.next_day_url
    end
    scrape_attributes
  end

  def scrape_attributes
  html = open(self.url)
  doc = Nokogiri::HTML(html)

  if doc.css("p").first.text == "Weather history data is not available for the date you have selected."
    error = "Weather history data is not available for the date you have selected."

  else
      self.date = doc.css("div.print-no form").attr("action").value.split("/")[-1]
      self.location_name = doc.css("h1").children[-1].text.strip.gsub("Weather History for ", "")
      self.weather_station = doc.css("h2.weatherhistory_results_station").text.strip.gsub("For the ", "")
      self.next_day_url = "https://www.almanac.com" + doc.css("td.nextprev_next a").attribute("href").value
      self.max_temp = doc.css("table.weatherhistory_results tr.weatherhistory_results_datavalue td p").children[6].text
      self.temp_units = doc.css("table.weatherhistory_results tr.weatherhistory_results_datavalue td p").children[2].text
      self.color = get_color
      convert_temp

      @@all << self
      TempestryPattern::Pattern.save(date, max_temp, temp_units, color_id, location, weather_station)
    end
  end

  def self.all
   @@all
  end

  def self.clear
    @@all.clear
  end

  def get_color
    TempestryPattern::Color.all[0].each do |color_row|
      binding.pry
      if self.max_temp.to_f.round >= color_row.min && self.max_temp.to_f.round <= color_row.max
        self.color = color_row.color
      end
    end
   self.color
  end

  def convert_temp
    if self.max_temp == "No data."
      self.max_temp = "No data available"
      self.min_temp = "No data available"
      self.mean_temp = "No data available"
      self.precipitation = "No data available"
      self.temp_units = ""
      self.color = "No data available"
    end
    if self.temp_units == "°C"
      self.max_temp = ((self.max_temp.to_f * 1.8) + 32).round
      self.min_temp = ((self.min_temp.to_f * 1.8) + 32).round
      self.mean_temp = ((self.mean_temp.to_f * 1.8) + 32).round
      self.temp_units = "°F"
    end
  end

end
