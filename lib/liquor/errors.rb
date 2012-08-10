module Liquor
  class Error < StandardError
  end

  class SourceMappedError < Error
    attr_reader :location

    def initialize(message, location=nil)
      location_info = ""
      if location
        if location.include? :file
          location_info << "`#{location[:file]}'"
        end

        if location.include? :line
          location_info << ": line #{location[:line] + 1}"
          if location.include? :start
            location_info << ", column #{location[:start] + 1}"
          end
        end
      end

      @location = location

      if location_info.empty?
        super(message)
      else
        super("#{message} at #{location_info}")
      end
    end

    def decorate(source)
      if @location && @location.has_key?(:line)
        line = source.lines.drop(@location[:line]).first

        if @location.has_key? :start
          pointer =  "~" * (@location[:start])
          if @location.has_key? :end
            pointer += "^" * (@location[:end] - @location[:start] + 1)
          else
            pointer += "^"
          end
        end
      end

      [ line, pointer ].compact
    end
  end

  class SyntaxError < SourceMappedError
  end

  class ArgumentError < SourceMappedError
  end

  class NameError < SourceMappedError
  end

  class TypeError < SourceMappedError
  end

  class ArgumentTypeError < Error
    attr_reader :location

    def initialize(message, location=nil)
      location_info = ""
      if location
        if location.include? :function
          location_info << "function `#{location[:function]}'"
          if location.include? :argument
            if location[:argument].nil?
              location_info << ", unnamed argument"
            else
              location_info << ", argument `#{location[:argument]}'"
            end
          end
        end
      end

      @location = location

      if location_info.empty?
        super(message)
      else
        super("#{message} at #{location_info}")
      end
    end
  end
end