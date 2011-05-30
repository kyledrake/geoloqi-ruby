module Geoloqi
  class Error < StandardError
    def initialize(type, message=nil)
      type += " - #{message}" if message
      super type
    end
  end
end