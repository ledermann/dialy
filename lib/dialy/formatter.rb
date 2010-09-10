module Dialy
  def self.format(value)
    # Remove all but digits and +
    plain = value.gsub(/[^+0-9]/, '')
    
    # Error check: Plus (+) is only allowed as first character
    raise ArgumentError if plain.count('+') > 1
    raise ArgumentError if plain.index('+').to_i > 0

    # Step 1: Find country code
    country_code = nil
    if match = plain.match(/^(\+|00)(\d{1,3})/)
      plain.slice!(0,match[1].length)
      
      # Because the length of a country code is not fixed, we have to do
      # multiple searches. Start with the minimum length and go to the 
      # maxium until an area code is found.
      CC_RANGE.each do |len|
        part = match[2][0,len].to_i
        
        if COUNTRY_CODES.include?(part)
          country_code = part
          plain.slice!(0,len)
          break
        end
      end
      
      raise ArgumentError.new("Unknown country code: #{match[2]}") unless country_code
    else
      country_code = Config[:default_country_code]
    end
    
    # Delete leading "0"
    plain.slice!(0,1) if plain.match /^0/

    # Step 2: Find area code
    area_code = nil
    if AREA_CODES[country_code]
      
      # Because the length of an area code is not fixed, we have to do
      # multiple searches. Start with the minimum length and go to the 
      # maxium until an area code is found.
      AC_RANGE[country_code].each do |len|
        part = plain[0,len].to_i
      
        if AREA_CODES[country_code].include?(part)
          area_code = part
          plain.slice!(0,len)
          break
        end
      end
      
      raise ArgumentError.new("Area code not found") unless area_code
    end
    
    # Finished. Build result
    "+#{country_code} #{[ area_code, plain ].compact.join(' ')}"
  end
end