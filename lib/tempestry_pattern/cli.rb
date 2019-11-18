class TempestryPattern::CLI
  attr_accessor :year, :zip, :name, :description
  @@all = []

  def call
    welcome
    options1
    menu_loop
  end

  def options1
    puts ""
    puts "What would you like to do?"
    puts ""
    puts "  S. SEARCH for a new year and zip code"
    puts "  V. VIEW and/or print all patterns"
    puts ""
    puts "Type a letter to make your choice. Type EXIT at any time."
    puts ""
  end

  def get_search_terms
    puts ""
    puts "SEARCH for daily weather data for a valid U.S. zip code, and a year between 1945 and the current year."
    @@all.clear
    puts ""

    puts "Enter a 5-digit zip code"
    self.zip = gets.strip
    if self.zip.size != 5
      self.zip = 12193
      puts ""
      puts "That does not appear to be a valid zip code. Check the preview, or enter new search terms."
      puts ""
    end
    puts ""

    puts "Enter a year"
    self.year = gets.strip
    if self.year.size != 4
      self.year = 1900
      puts ""
      puts "That does not appear to be a valid year. Check the preview, or enter new search terms."
      puts ""
    end
    puts ""

    puts "Enter your name"
    self.name = gets.strip
    puts ""

    puts "Enter a project description"
    self.description = gets.strip
    @@all << self
  end

  def options
    puts ""
    puts "What would you like to do?"
    puts ""
    puts "  S. SEARCH for a new year and zip code"
    puts "  P. PREVIEW pattern"
    puts "  C. CREATE and print full pattern (Note: This takes 20 minutes)"
    puts "  V. VIEW and/or print all patterns"
    puts ""
    puts "Type a letter to make your choice. Type EXIT at any time."
    puts ""
  end

  def menu_loop
    input = nil
    while input != "EXIT" && input != "exit"
      input = gets.strip.upcase

      case input
        when "P" || "p"
          puts ""
          puts "Please wait while we PREVIEW your pattern"
          puts ""
          TempestryPattern::Pattern.preview
          if TempestryPattern::Pattern.preview_all[0].date == nil
            puts ""
            puts "  ERROR: Please try again. Weather history data is not available for the date and location you have selected."
            puts ""
          else
            print_preview
            puts ""
            puts "If this preview looks correct, choose C to create a pattern for the entire year"
            puts ""
          end
          options

        when "S" || "s"
          get_search_terms
          options

        when "C" || "c"
          puts ""
          puts "Please wait about 20 minutes while we CREATE your pattern"
          puts ""
          puts "While you are waiting, learn more about the Tempestry Project by watching this video: https://youtu.be/30nG81Fu7yg"
          puts ""
          TempestryPattern::Pattern.year
          TempestryPattern::Pattern.save
          print_year
          options

        when "V" || "v"
          view_patterns
          choose_pattern
          options

        when "EXIT" || "exit"
          goodbye

        else
          options
        end
       end
     end

  def print_preview
    if TempestryPattern::Scraper.all == nil
      puts ""
      puts "  ERROR: Please try again. Weather history data is not available for the date and location you have selected."
      puts ""
      get_search_terms

    else
      puts ""
      puts "    Here is your daily maximum temperature data for #{TempestryPattern::Pattern.preview_all[0].location_name}."
      puts ""
      puts "    Complete?  Row #    Date           Max Temperature    Yarn Color"
      puts ""

      TempestryPattern::Pattern.preview_all.each.with_index(1) do |day, i|
        if day.max_temp.to_f.round.between?(0, 9)
          temp_spacer = "  "
        elsif day.max_temp.to_f.round.between?(10, 99) || day.max_temp.between?(-9, -1)
          temp_spacer = " "
        else
          temp_spacer = ""
        end

        puts "    ________   #{i}.       #{day.date}     #{temp_spacer}#{day.max_temp.to_f.round} #{day.temp_units}             #{day.color}"
      end
    end
    puts ""
  end

  def print_year
    TempestryPattern::Pattern.create_pattern
    puts ""
    puts "    Here is your complete knitting pattern for #{TempestryPattern::Pattern.create_pattern[0].location_name}."
    puts ""
    puts "    Complete?  Row #    Date             Max Temperature    Yarn Color"
    puts ""

    TempestryPattern::Pattern.create_pattern.each.with_index(1) do |day, i|
        if i.between?(1, 9)
          row_spacer = "  "
        elsif i.between?(10, 99)
          row_spacer = " "
        else
          row_spacer = ""
        end

        if day.max_temp.to_f.round.between?(0, 9)
          temp_spacer = "  "
        elsif day.max_temp.to_f.round.between?(10, 99) || day.max_temp.to_f.round.between?(-9, -1)
          temp_spacer = " "
        else
          temp_spacer = ""
        end

        puts "    ________   #{row_spacer}#{i}.     #{day.date}       #{temp_spacer}#{day.max_temp.to_f.round} #{day.temp_units}             #{day.color}"
    end
    puts ""
  end

  def view_patterns
    sql = "SELECT DISTINCT zip, year, name, description FROM patterns;"
    list = DB2[:conn].execute(sql)

      puts "Here is a list of all of the Tempestry Patterns saved in the database"
      puts ""
      puts "Number       Zip         Year       Name  and  Description"
      puts ""

    list.each.with_index(1) do |row, i|
      if i.between?(1, 9)
        row_spacer = "  "
      elsif i.between?(10, 99)
        row_spacer = " "
      else
        row_spacer = ""
      end
      puts "#{row_spacer}#{i}.         #{row[0]}       #{row[1]}       #{row[2]}  ---  #{row[3]}"
    end
  end

  def choose_pattern
    puts ""
    puts "Choose a row number to view or print the pattern"
    puts ""

    list = DB2[:conn].execute("SELECT DISTINCT zip, year, name, description FROM patterns;")
    input = gets.strip.to_i
    sql = "SELECT * FROM patterns WHERE zip = ? AND year = ? AND name = ? AND description = ?"
    pattern = DB2[:conn].execute(sql, list[input-1][0], list[input-1][1], list[input-1][2], list[input-1][3])
    year = []
    pattern.map do |row|
      year << TempestryPattern::Pattern.new_from_db(row)
    end

    puts "    Here is your complete knitting pattern for #{year[0].location_name} --- #{year[0].zip} --- #{year[0].year}"
    puts "    Created by: #{year[0].name}"
    puts "    Description: #{year[0].description}"
    puts ""
    puts "    Complete?  Row #    Date             Max Temperature    Yarn Color"
    puts ""

    year.each.with_index(1) do |day, i|
        if i.between?(1, 9)
          row_spacer = "  "
        elsif i.between?(10, 99)
          row_spacer = " "
        else
          row_spacer = ""
        end

        if day.max_temp.to_f.round.between?(0, 9)
          temp_spacer = "  "
        elsif day.max_temp.to_f.round.between?(10, 99) || day.max_temp.to_f.round.between?(-9, -1)
          temp_spacer = " "
        else
          temp_spacer = ""
        end
        puts "    ________   #{row_spacer}#{i}.     #{day.date}       #{temp_spacer}#{day.max_temp.to_f.round} #{day.temp_units}             #{day.color}"
    end
    puts ""
  end

  def self.zip
    @@all[0].zip
  end

  def self.year
    @@all[0].year
  end

  def self.name
    @@all[0].name
  end

  def self.description
    @@all[0].description
  end

  def welcome
    puts ""
    puts "Welcome to the Tempestry Pattern Generator"
    puts ""
    puts "The Tempestry Pattern Generator will create a custom knitting or crochet pattern based on the daily maximum temperature for a year."
    puts "Each yarn color represents a 5-degree range of temperature."
    puts ""
  end

  def goodbye
    puts ""
    puts "Thank you for using the Tempestry Pattern Generator"
    puts ""
  end

  def self.all
    @@all
  end
end
