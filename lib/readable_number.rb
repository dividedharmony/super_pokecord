# frozen_string_literal: true

class ReadableNumber
  DELIMITER_CHAR = ','.freeze
  SEPARATOR_CHAR = '.'.freeze
  DELIMITER_REGEX = /(\d)(?=(\d\d\d)+(?!\d))/

  class << self
    def stringify(number)
      left, right = number.to_s.split(SEPARATOR_CHAR)
      left.gsub!(DELIMITER_REGEX) do |digit_to_delimit|
        "#{digit_to_delimit}#{DELIMITER_CHAR}"
      end
      [left, right].compact.join(SEPARATOR_CHAR)
    end
  end
end
