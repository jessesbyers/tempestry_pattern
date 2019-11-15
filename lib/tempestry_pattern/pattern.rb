class TempestryPattern::Pattern
  attr_accessor :id, :date, :location_name, :weather_station, :max_temp, :temp_units, :color
  @@all = []
  @@preview_all = []

  # def self.table_name
  #    self.to_s.downcase.pluralize
  # end

  # def self.column_names
  #   DB2[:conn].results_as_hash = true
  #
  #   sql = "pragma table_info('patterns')"
  #
  #   table_info = DB2[:conn].execute(sql)
  #   column_names = []
  #   table_info.each do |row|
  #     column_names << row["name"]
  #   end
  #   column_names.compact
  # end

  def initialize(options={})
    options.each do |property, value|
    self.send("#{property}=", value)
    end
  end

  # def table_name_for_insert
  #   self.class.table_name
  # end

  # def col_names_for_insert
  #   self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  # end

  # def values_for_insert
  #   values = []
  #   self.class.column_names.each do |col_name|
  #     values << "'#{send(col_name)}'" unless send(col_name).nil?
  #   end
  #   values.join(", ")
  # end

  def self.save
    sql = "INSERT INTO patterns (date, location_name, weather_station, max_temp, temp_units, color) VALUES (?, ?, ?, ?, ?, ?)"
    DB2[:conn].execute(sql)
    @id = DB2[:conn].execute("SELECT last_insert_rowid() FROM patterns")[0][0]
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
