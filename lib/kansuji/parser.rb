# encoding: UTF-8
module Kansuji
  module Parser
    POWER_OF_TEN_TO_INTEGER = {
      "十" => 10,
      "百" => 100,
      "千" => 1000
    }

    POWER_OF_MAN = %w(万 億 兆 京 垓 𥝱 穣 溝 澗 正 載 極 恒河沙 阿僧祇 那由他 不可思議 無量大数)
    POWER_OF_MAN_TO_INTEGER =
      POWER_OF_MAN.each.with_index.inject({}){|table, (char, i)|
        table[char] = 10000 ** (i + 1)
        table
      }

    # Reference: http://ja.wikipedia.org/w/index.php?title=%E5%A4%A7%E5%AD%97_(%E6%95%B0%E5%AD%97)&oldid=42692394
    VARIATIONS = {
      /零/ => "〇",
      /[壱壹]/ => "一",
      /[弐貮貳]/ => "二",
      /[参參]/ => "三",
      /肆/ => "四",
      /伍/ => "五",
      /陸/ => "六",
      /[柒漆質]/ => "七",
      /捌/ => "八" ,
      /玖/ => "九",
      /拾/ => "十",
      /[廿卄]/ => "二十", # Convert to 'traditional' notaion, because it was used only in that notation.
      /[卅丗]/ => "三十",
      /[陌佰]/ => "百",
      /[阡仟]/ => "千",
      /萬/ => "万",
      /秭/ => "𥝱"
    }

    module_function

    # Convert various type of Kansuji to Fixnum
    # Kansuji::Parser.to_i("一二五〇〇〇〇〇〇") #=> 125000000
    # Kansuji::Parser.to_i("一億二五〇〇万") #=> 125000000
    # Kansuji::Parser.to_i("1億2500万") #=> 125000000
    # Kansuji::Parser.to_i("１億２５００万") #=> 125000000
    # Kansuji::Parser.to_i("一億二千五百万") #=> 125000000
    # Kansuji::Parser.to_i("廿壱萬") #=> 210000
    def to_i(kansuji)
      kansuji = normalize(kansuji) # 参 to 三
      kansuji = replace_arabic_to_kansuji(kansuji) # 3 or ３ to 三
      kansuji.strip!
      case kansuji
      when /^[〇一二三四五六七八九]+$/
        replace_to_i(kansuji)
      when /(〇|[一二三四五六七八九]{2})/
        mixed_to_i(kansuji)
      else
        traditional_to_i(kansuji)
      end
    end

    # normalize("廿壱萬") # => "二十一万"
    def normalize(kansuji)
      kansuji = kansuji.dup
      VARIATIONS.each do |pattern, normalized|
        kansuji.gsub!(pattern, normalized)
      end
      kansuji
    end

    # private module functions
    class << self
      private

      # replace_arabic_to_kansuji("1億2000万") #=> "一億二〇〇〇万"
      # replace_arabic_to_kansuji("２０１２") #=> "二〇一二"
      def replace_arabic_to_kansuji(arabic)
        arabic.tr("０１２３４５６７８９", "0123456789").
               tr("0123456789", "〇一二三四五六七八九")
      end

      # replace_to_i("一二五〇〇〇〇〇〇") #=> 125000000
      def replace_to_i(kansuji)
        kansuji.tr("〇一二三四五六七八九", "0123456789").to_i
      end

      # mixed_to_i("一億二五〇〇万") #=> 125000000
      def mixed_to_i(kansuji)
        i = 0
        # Split "一億二五〇〇万" to ["一", "億", "二五〇〇", "万"] and process by pair
        kansuji.split(power_of_man_regexp).each_slice(2) do |four, power_of_man|
          k = power_of_man_to_i(power_of_man) || 1
          i += replace_to_i(four) * k
        end
        i
      end

      # traditional_to_i("一億二千五百万") #=> 125000000
      def traditional_to_i(kansuji)
        i = 0
        # Split "一億二千五百万" to ["一", "億", "二千五百", "万"] and process by pair
        kansuji.split(power_of_man_regexp).each_slice(2) do |four, power_of_man|
          k = power_of_man_to_i(power_of_man) || 1
          i += traditional_four_to_i(four) * k
        end
        i
      end

      # traditional_four_to_i("二千百三") #=> 2103
      def traditional_four_to_i(kansuji)
        raise ParseError unless kansuji =~ traditional_four_regexp
        i = 0
        # If kansuji == "二千百三" then $~.captures == ["二", "千", "", "百", nil, nil, "一"]
        $~.captures.each_slice(2) do |one_to_nine, power_of_ten|
          next unless one_to_nine || power_of_ten # nil, nil
          k = power_of_ten_to_i(power_of_ten) || 1 # power_of_ten for lowest order is nil, then set 1
          n = one_to_nine == "" ? 1 : replace_to_i(one_to_nine) # one_to_nine for 1000, 100, 10 is "", then set 1
          i += n * k
        end
        i
      end

      # power_of_man_to_i("万") #=> 10000
      # power_of_man_to_i("億") #=> 100000000
      # power_of_man_to_i("京") #=> 1000000000000
      # power_of_man_to_i(unexpected) #=> nil
      def power_of_man_to_i(power_of_man)
        POWER_OF_MAN_TO_INTEGER[power_of_man]
      end

      # Regexp to match any power of ten string
      def power_of_man_regexp
        # /(万|億|京)/
        @power_of_man_regexp ||= Regexp.compile("(" + POWER_OF_MAN.map{|s| Regexp.escape(s) }.join("|") + ")")
      end

      # power_of_ten_to_i("十") #=> 10
      # power_of_ten_to_i("百") #=> 100
      # power_of_ten_to_i("千") #=> 1000
      # power_of_ten_to_i(unexpected) #=> nil
      def power_of_ten_to_i(power_of_ten)
        POWER_OF_TEN_TO_INTEGER[power_of_ten]
      end

      # Regexp to match traditional notation for (1..9999)
      # "二千百三" =~ Kansuji.traditional_four_regexp
      # $~.captures == ["二", "千", "", "百", nil, nil, "三"]
      def traditional_four_regexp
        /(?:([一二三四五六七八九]?)(千))?(?:([二三四五六七八九]?)(百))?(?:([二三四五六七八九]?)(十))?([一二三四五六七八九])?/
      end
    end
  end
end
