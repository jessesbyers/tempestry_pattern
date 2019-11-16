class TempestryPattern::Color
  attr_accessor :id, :color, :min, :max
  @@color_objects = []

  def self.new_from_db(row)
    new_color = self.new
    new_color.id = row[0]
    new_color.color = row[1]
    new_color.min = row[2]
    new_color.max = row[3]
    new_color
  end

  def self.all
    sql = <<-SQL
      SELECT *
        FROM colors
    SQL
    DB[:conn].execute(sql).map do |row|
     @@color_objects << self.new_from_db(row)
    end
   end

   def self.colors
     @@color_objects
   end
  end

  # def self.find_by_color(color)
  #   sql = <<-SQL
  #     SELECT *
  #     FROM colors
  #     WHERE color = ?
  #     LIMIT 1
  #   SQL
  #
  #   DB[:conn].execute(sql, name).map do |row|
  #     self.new_from_db(row)
  #   end.first
  # end

  # def self.create_table
  #   sql = <<- SQL
  #     CREATE TABLE IF NOT EXISTS colors (
  #       id INTEGER PRIMARY KEY,
  #       color TEXT,
  #       min INTEGER,
  #       MAX INTEGER
  #     )
  #   SQL
  #   DB[:conn].execute(sql)
  # end
