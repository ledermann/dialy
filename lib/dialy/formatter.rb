module Dialy
  class UnknownCountryCode < ArgumentError; end
  class UnknownAreaCode < ArgumentError; end
  class WrongFormatting < ArgumentError; end
    
  def self.format(value)
    # Remove all but digits and +
    plain = value.gsub(/[^+0-9]/, '')
    
    # Error check: Plus (+) is only allowed as first character
    raise WrongFormatting if plain.count('+') > 1
    raise WrongFormatting if plain.index('+').to_i > 0

    # Step 1: Find country code
    if country_code = extract_country_code(plain)
      plain.slice!(0,country_code.to_s.length)
    else
      country_code = Config[:default_country_code]
    end
    
    # Delete leading "0"
    plain.slice!(0,1) if plain.match /^0/

    # Step 2: Find area code
    if area_code = extract_area_code(country_code, plain)
      plain.slice!(0,area_code.to_s.length)
    end
    
    # Finished. Build result
    "+#{country_code} #{[ area_code, plain ].compact.join(' ')}"
  end
  
private
  def self.extract_country_code(value)
    if match = value.match(/^(\+|00)(\d{1,3})/)
      # Remove "+" or leading "00"
      value.slice!(0,match[1].length)
      
      # Because the length of a country code is not fixed, we have to do
      # multiple searches. Start with the minimum length and go to the 
      # maxium until an area code is found.
      CC_RANGE.each do |len|
        part = match[2][0,len].to_i
        return part if COUNTRY_CODES.include?(part)
      end
      
      raise UnknownCountryCode.new("Unknown country code: #{match[2]}") 
    end
  end
  
  def self.extract_area_code(country_code, value)
    if AREA_CODES[country_code]
      # Because the length of an area code is not fixed, we have to do
      # multiple searches. Start with the minimum length and go to the 
      # maxium until an area code is found.
      AC_RANGE[country_code].each do |len|
        part = value[0,len].to_i
      
        return part if AREA_CODES[country_code].include?(part)
      end
      
      raise UnknownAreaCode.new('Unknown area code')
    end
  end
end