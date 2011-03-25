module Dialy
  class UnknownCountryCode < ArgumentError; end
  class UnknownAreaCode < ArgumentError; end
  class WrongFormatting < ArgumentError; end
    
  class Number  
    def initialize(value)
      raise ArgumentError unless value.is_a?(String)
      
      # Remove all but digits and +
      @number = value.gsub(/[^+0-9]/, '')
    
      # Plus (+) is only allowed as first character
      raise WrongFormatting if @number.count('+') > 1
      raise WrongFormatting if @number.index('+').to_i > 0

      # Main work
      @country_code = extract_country_code! || Config[:default_country_code]
      @area_code = extract_area_code!
    end
    
    # String representation in E.123 format
    def to_s(format=:international)
      case format
        when :international
          "+#{@country_code} #{[ @area_code, @number ].compact.join(' ')}"
        when :short
          if @country_code == Config[:default_country_code]
            "(0#{@area_code}) #{@number}"
          else
            to_s(:international)
          end
        else
          raise ArgumentError
      end
    end
  
  private
    def extract_country_code!
      if match = @number.match(/^(\+|00)(\d{1,3})/)
        # Because the length of a country code is not fixed, we have to do
        # multiple searches. Start with the minimum length and go to the 
        # maxium until an area code is found.
        CC_RANGE.each do |len|
          part = match[2][0,len].to_i
        
          if COUNTRY_CODES.include?(part)
            # Remove "+" or leading "00"
            @number.slice!(0,match[1].length)
          
            # Strip country code 
            @number.slice!(0,part.to_s.length)
          
            return part
          end
        end
      
        raise UnknownCountryCode.new("Unknown country code: #{match[2]}") 
      end
    end
  
    def extract_area_code!
      # Delete leading "0"
      @number.slice!(0,1) if @number.match /^0/
    
      if AREA_CODES[@country_code]
        # Because the length of an area code is not fixed, we have to do
        # multiple searches. Start with the minimum length and go to the 
        # maxium until an area code is found.
        AC_RANGE[@country_code].each do |len|
          part = @number[0,len].to_i
      
          if AREA_CODES[@country_code].include?(part)
            # Strip area_code
            @number.slice!(0,part.to_s.length)
          
            return part 
          end
        end
      
        raise UnknownAreaCode.new('Unknown area code')
      end
    end
  end
end