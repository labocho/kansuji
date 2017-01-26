# encoding: UTF-8
require "kansuji/version"

# Kansuji: Japanese Kansuji (chinese numerals) utility
# - Convert various type of Kansuji string to Fixnum
# - Only support integer, cannot recognize 割, 分 etc...
# Reference: http://ja.wikipedia.org/w/index.php?title=%E6%BC%A2%E6%95%B0%E5%AD%97&oldid=43573289
module Kansuji
  class ParseError < StandardError; end
  autoload :Builder, "kansuji/builder"
  autoload :CUI, "kansuji/cui"
  autoload :Parser, "kansuji/parser"

  POWER_OF_MAN = %w(万 億 兆 京 垓 𥝱 穣 溝 澗 正 載 極 恒河沙 阿僧祇 那由他 不可思議 無量大数)

  module_function
  # Convert various type of Kansuji to Fixnum
  # Kansuji.to_i("一二五〇〇〇〇〇〇") #=> 125000000
  # Kansuji.to_i("一億二五〇〇万") #=> 125000000
  # Kansuji.to_i("1億2500万") #=> 125000000
  # Kansuji.to_i("１億２５００万") #=> 125000000
  # Kansuji.to_i("一億二千五百万") #=> 125000000
  # Kansuji.to_i("廿壱萬") #=> 210000
  def to_i(kansuji)
    Parser.to_i(kansuji)
  end

  # Convert all kansuji to arabic in argument
  def to_arabic(string_with_kansuji, type = nil)
     Parser.to_arabic(string_with_kansuji, type)
  end

  # Kansuji.normalize("廿壱萬") # => "二十一万"
  def normalize(kansuji)
    Parser.normalize(kansuji)
  end

  def to_kansuji(i, type = :traditional)
    Builder.to_kansuji(i, type)
  end
end
