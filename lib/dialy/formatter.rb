module Dialy
  class UnknownCountryCode < ArgumentError; end
  class UnknownAreaCode < ArgumentError; end
  class WrongFormatting < ArgumentError; end
    
  def self.format(value)
    # Step 1: Strip unwanted chars
    strip!(value)

    # Step 2: Find country code
    country_code = extract_country_code!(value) || Config[:default_country_code]
    
    # Step 3: Find area code
    area_code = extract_area_code!(country_code, value)
    
    # Step 4: Build result
    "+#{country_code} #{[ area_code, value ].compact.join(' ')}"
  end
  
private
  def self.strip!(value)
    # Remove all but digits and +
    value.gsub!(/[^+0-9]/, '')
    
    # Error check: Plus (+) is only allowed as first character
    raise WrongFormatting if value.count('+') > 1
    raise WrongFormatting if value.index('+').to_i > 0
  end

  def self.extract_country_code!(value)
    if match = value.match(/^(\+|00)(\d{1,3})/)
      # Because the length of a country code is not fixed, we have to do
      # multiple searches. Start with the minimum length and go to the 
      # maxium until an area code is found.
      CC_RANGE.each do |len|
        part = match[2][0,len].to_i
        
        if COUNTRY_CODES.include?(part)
          # Remove "+" or leading "00"
          value.slice!(0,match[1].length)
          
          # Strip country code 
          value.slice!(0,part.to_s.length)
          
          return part
        end
      end
      
      if match[1] == '00'
        # Seems to be not a country_code, so remove the first "0" and use it as local number
        value.slice!(0,1)
        return
      end
      
      raise UnknownCountryCode.new("Unknown country code: #{match[2]}") 
    end
  end
  
  def self.extract_area_code!(country_code, value)
    # Delete leading "0"
    value.slice!(0,1) if value.match /^0/
    
    if AREA_CODES[country_code]
      # Because the length of an area code is not fixed, we have to do
      # multiple searches. Start with the minimum length and go to the 
      # maxium until an area code is found.
      AC_RANGE[country_code].each do |len|
        part = value[0,len].to_i
      
        if AREA_CODES[country_code].include?(part)
          # Strip area_code
          value.slice!(0,part.to_s.length)
          
          return part 
        end
      end
      
      raise UnknownAreaCode.new('Unknown area code')
    end
  end
end