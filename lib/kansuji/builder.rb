# encoding: UTF-8
module Kansuji
  module Builder
    INTEGER_TO_POWER_OF_MAN =
      Kansuji::POWER_OF_MAN.each_with_index.map{|char, i|
        [char, 10000 ** (i + 1)]
      }.reverse
    INTEGER_TO_POWER_OF_TEN = [
      ["千", 1000],
      ["百", 100],
      ["十", 10]
    ]

    module_function

    def to_kansuji(i, type = :traditional)
      case type
      when :replace
        replace_to_kansuji(i)
      when :mixed
        to_mixed_kansuji(i)
      when :mixed_arabic
        to_mixed_arabic_kansuji(i)
      when :traditional
        to_traditional_kansuji(i)
      else
        raise "Unknown Kansuji notation type #{type.inspect}, only supported (:replace|:mixed|:traditional)"
      end
    end

    def replace_to_kansuji(i)
      i.to_s.tr("0123456789", "〇一二三四五六七八九")
    end

    def to_mixed_kansuji(number)
      return "〇" if number == 0
      kansuji = ""
      INTEGER_TO_POWER_OF_MAN.each do |char, i|
        four = number / i
        number = number % i
        next if four == 0
        kansuji << replace_to_kansuji(four).rjust(4, "〇") + char
      end
      kansuji << replace_to_kansuji(number).rjust(4, "〇") if number > 0 # 1-9999
      kansuji.gsub(/^〇+/, "")
    end

    def to_mixed_arabic_kansuji(number)
      return "0" if number == 0
      kansuji = ""
      INTEGER_TO_POWER_OF_MAN.each do |char, i|
        four = number / i
        number = number % i
        next if four == 0
        kansuji << four.to_s.rjust(4, "0") + char
      end
      kansuji << number.to_s.rjust(4, "0") if number > 0 # 1-9999
      kansuji.gsub(/^0+/, "")
    end

    def to_traditional_kansuji(number)
      return "〇" if number == 0
      kansuji = ""
      INTEGER_TO_POWER_OF_MAN.each do |char, i|
        four = number / i
        number = number % i
        next if four == 0
        kansuji << to_traditional_four_kansuji(four) + char
      end
      kansuji << to_traditional_four_kansuji(number) if number > 0 # 1-9999
      kansuji
    end

    # to_traditional_four_kansuji(1234) #=> 千二百三十四
    # to_traditional_four_kansuji(0) # => 〇
    def to_traditional_four_kansuji(number)
      return "〇" if number == 0
      kansuji = ""
      INTEGER_TO_POWER_OF_TEN.each do |char, i|
        k = number / i
        number = number % i

        case k
        when 0
          # ignore
        when 1
          kansuji << char
        else
          kansuji << (replace_to_kansuji(k) + char)
        end
      end
      kansuji << replace_to_kansuji(number) if number > 0
      kansuji
    end
  end
end
