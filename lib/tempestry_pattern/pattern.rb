class TempestryPattern::Pattern
  attr_accessor :id, :date, :location_name, :weather_station, :max_temp, :temp_units, :color, :zip, :year, :name, :description
  @@all = []
  @@preview_all = []

  def self.save
    if !self.find_by_search_terms(TempestryPattern::CLI.zip, TempestryPattern::CLI.year, TempestryPattern::CLI.name, TempestryPattern::CLI.description).empty?
      puts "This pattern has already been saved in the archive"
    else
      TempestryPattern::Scraper.all.each do |day|
        sql = "INSERT INTO patterns (date, location_name, weather_station, max_temp, temp_units, color, zip, year, name, description)
          VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
        DB2[:conn].execute(sql, day.date, day.location_name, day.weather_station, day.max_temp, day.temp_units, day.color, day.zip, day.year, day.name, day.description)
        @id = DB2[:conn].execute("SELECT last_insert_rowid() FROM patterns")[0][0]
      end
    end
  end

  def self.find_by_search_terms(zip, year, name, description)
    sql = "SELECT * FROM patterns WHERE zip = ? AND year = ? AND name = ? AND description = ?"
    pattern = DB2[:conn].execute(sql, TempestryPattern::CLI.zip, TempestryPattern::CLI.year, TempestryPattern::CLI.name, TempestryPattern::CLI.description)
  end

  def self.new_from_db(row)
     new_day = self.new
     new_day.id = row[0]
     new_day.date = row[1]
     new_day.location_name = row[2]
     new_day.weather_station = row[3]
     new_day.max_temp = row[4]
     new_day.temp_units = row[5]
     new_day.color = row[6]
     new_day.zip = row[7]
     new_day.year = row[8]
     new_day.name = row[9]
     new_day.description = row[10]
     new_day
   end

   def self.create_pattern
     pattern = self.find_by_search_terms(TempestryPattern::CLI.zip, TempestryPattern::CLI.year, TempestryPattern::CLI.name, TempestryPattern::CLI.description)
     year = []
     pattern.map do |row|
       year << self.new_from_db(row)
     end
     year
   end

  def self.preview
    TempestryPattern::Scraper.clear
    @@preview_all.clear
    5.times do
      @@preview_all << TempestryPattern::Scraper.new
    end
  end

  def self.year
    TempestryPattern::Scraper.clear
    @@all.clear
    if Date.leap?(TempestryPattern::CLI.year.to_i)
      13.times do
        @@all << TempestryPattern::Scraper.new
      end
    else
      12.times do
        @@all << TempestryPattern::Scraper.new
      end
    end
  end

  def self.all
    @@all
  end

  def self.preview_all
    @@preview_all
  end
end
