require "optparse"
module Kansuji
  class CUI
    def self.run(argv)
      new.run(argv)
    end

    def run(argv)
      opts = {
        notation: nil
      }
      OptionParser.new do |o|
        o.on("--arabic", "Convert Kansuji to arabic [default]") {}
        o.on("--traditional", "Convert arabic to Kansuji (traditional)") {
          opts[:notation] = :traditional
        }
        o.on("--replace", "Convert arabic to Kansuji (replace)") {
          opts[:notation] = :replace
        }
        o.on("--mixed", "Convert arabic to Kansuji (mixed)") {
          opts[:notation] = :mixed
        }
        o.on("--mixed-arabic", "Convert arabic to Kansuji (mixed-arabic)") {
          opts[:notation] = :mixed_arabic
        }
        o.parse! argv
      end

      case opts[:notation]
      when nil
        argv.each do |s|
          puts Kansuji.to_i(s)
        end
      else
        argv.each do |s|
          puts Kansuji.to_kansuji(s.to_i, opts[:notation])
        end
      end
    end
  end
end
