# revise v option so user can choose pattern and re-print it (see old choose day method)

class TempestryPattern::CLI
  attr_accessor :year, :zip, :name, :description
  @@all = []

  def call
    welcome
    get_search_terms
    options1
    menu_loop
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

  def options1
    puts ""
    puts "What would you like to do?"
    puts ""
    puts "  P. PREVIEW pattern"
    puts "  S. SEARCH for a new year and zip code"
    puts ""
    puts "Type a letter to make your choice. Type EXIT at any time."
    puts ""
  end

  def options2
    puts ""
    puts "What would you like to do?"
    puts ""
    puts "  C. CREATE and print full pattern"
    puts "  S. SEARCH for a new year and zip code"
    puts ""
    puts "Type a letter to make your choice. Type EXIT at any time."
    puts ""
  end

  def options3
    puts ""
    puts "What would you like to do?"
    puts ""
    # puts "  A. ARCHIVE (save) pattern"
    puts "  V. VIEW all patterns"
    puts "  R. RE-PRINT full pattern"
    puts "  S. SEARCH for a new year and zip code"
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
          options2

        when "S" || "s"
          get_search_terms
          options1

        when "C" || "c"
          puts ""
          puts "Please wait about 20 minutes while we CREATE your pattern"
          puts ""
          puts "While you are waiting, learn more about the Tempestry Project by watching this video: https://youtu.be/30nG81Fu7yg"
          puts ""
          TempestryPattern::Pattern.year
          TempestryPattern::Pattern.save
          print_year
          options3

        when "V" || "v"
          TempestryPattern::Pattern.view_patterns
          options3

        when "R" || "r"
          print_year
          options3

        when "EXIT" || "exit"
          goodbye

        else
          options1
        end
       end
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
end

# when "A" || "a"
#   TempestryPattern::Pattern.save
#   options3
