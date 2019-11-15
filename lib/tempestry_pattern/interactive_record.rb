require_relative "../config/environment.rb"
require 'active_support/inflector'

class TempestryPattern::InteractiveRecord

  def self.table_name
     self.to_s.downcase.pluralize
  end

  def self.column_names
    DB2[:conn].results_as_hash = true

    sql = "pragma table_info('#{table_name}')"

    table_info = DB2[:conn].execute(sql)
    column_names = []
    table_info.each do |row|
      column_names << row["name"]
    end
    column_names.compact
  end

  def initialize(options={})
    options.each do |property, value|
    self.send("#{property}=", value)
    end
  end

  def table_name_for_insert
    self.class.table_name
  end

  def col_names_for_insert
    self.class.column_names.delete_if {|col| col == "id"}.join(", ")
  end

  def values_for_insert
    values = []
    self.class.column_names.each do |col_name|
      values << "'#{send(col_name)}'" unless send(col_name).nil?
    end
    values.join(", ")
  end

  def save
    sql = "INSERT INTO #{table_name_for_insert} (#{col_names_for_insert}) VALUES (#{values_for_insert})"
    DB2[:conn].execute(sql)
    @id = DB2[:conn].execute("SELECT last_insert_rowid() FROM #{table_name_for_insert}")[0][0]
  end

  def self.find_by_name(name)
    sql = "SELECT * FROM #{self.table_name} WHERE name = ?"
    DB2[:conn].execute(sql, name)
  end

def self.find_by(attribute={})
    attribute.each do |key, value|
      sql = "SELECT * FROM #{self.table_name} WHERE #{key} = ?"
      binding.pry
      return DB2[:conn].execute(sql, value)
    end
  end
end