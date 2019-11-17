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
