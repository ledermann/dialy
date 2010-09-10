require File.expand_path(File.dirname(__FILE__) + '/data/countries')

module Dialy
  AREA_CODES = {}
  AC_RANGE = {}
end

require File.expand_path(File.dirname(__FILE__) + "/data/de")
require File.expand_path(File.dirname(__FILE__) + "/data/ch")
require File.expand_path(File.dirname(__FILE__) + "/data/at")

module Dialy
  # Calc the minimum and maximum length of the area codes
  AREA_CODES.each_pair do |country_code, area_codes|
    min_length = Math.log10(area_codes.min).to_i + 1
    max_length = Math.log10(area_codes.max).to_i + 1
    
    AC_RANGE[country_code] = (min_length..max_length)
  end
  
  # same for country codes
  min_length = Math.log10(COUNTRY_CODES.min).to_i + 1
  max_length = Math.log10(COUNTRY_CODES.max).to_i + 1
  CC_RANGE = (min_length..max_length)
end