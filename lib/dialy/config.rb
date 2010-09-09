module Dialy
  module Config
    DEFAULT_OPTIONS = {
      :default_country_code => '49'
    }
    @options = DEFAULT_OPTIONS.clone

    def [](key)
      @options[key.to_sym]
    end

    def []=(key, value)
      @options[key.to_sym] = value
    end

    module_function :[], :[]=
  end
end