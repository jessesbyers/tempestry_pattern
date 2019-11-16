class TempestryPattern::Pattern
  attr_accessor :id, :date, :location_name, :weather_station, :max_temp, :temp_units, :color, :zip, :year, :name, :description
  @@all = []
  @@preview_all = []

  def self.save
    TempestryPattern::Scraper.all.each do |day|
      sql = "INSERT INTO patterns (date, location_name, weather_station, max_temp, temp_units, color, zip, year, name, description)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?);"
      DB2[:conn].execute(sql, day.date, day.location_name, day.weather_station, day.max_temp, day.temp_units, day.color, day.zip, day.year, day.name, day.description)
      @id = DB2[:conn].execute("SELECT last_insert_rowid() FROM patterns")[0][0]
    end
    DB2[:conn].execute("SELECT * FROM patterns;")
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM patterns WHERE name = ?"
    DB2[:conn].execute(sql, name)
  end

  def self.find_by(attribute={})
     attribute.each do |key, value|
     sql = "SELECT * FROM patterns WHERE #{key} = ?"
     binding.pry
     return DB2[:conn].execute(sql, value)
    end
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


  # def initialize(options={})
  #   options.each do |property, value|
  #   self.send("#{property}=", value)
  #   end
  # end
