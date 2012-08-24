# encoding: UTF-8
require "spec_helper"

describe Kansuji do
  describe ".to_i" do
    subject { Kansuji.to_i(@src) }
    context "type: replace" do
      it "should return 1023456789 for '一〇二三四五六七八九'" do
        @src = "一〇二三四五六七八九"
        should == 10_2345_6789
      end
    end
    context "type: mixed" do
      it "should parse '一〇億二三四五万六七八九'" do
        @src = "一〇億二三四五万六七八九"
        should == 10_2345_6789
      end
      it "should parse '10億2345万6789" do
        @src = "10億2345万6789"
        should == 10_2345_6789
      end
      it "should parse '１０億２３４５万６７８９" do
        @src = "１０億２３４５万６７８９"
        should == 10_2345_6789
      end
      it "should parse ommission of four orders" do
        @src = "一億二三四五"
        should == 1_0000_2345
      end
      it "should parse max order" do
        @src = "1無量大数2345不可思議6789那由他0123阿僧祇4567恒河沙8901極2345載6789正0123澗4567溝8901穣2345𥝱6789垓0123京4567兆8901億2345万6789"
        should == 1_2345_6789_0123_4567_8901_2345_6789_0123_4567_8901_2345_6789_0123_4567_8901_2345_6789
      end
    end
    context "type: traditional" do
      it "should return 123456789 for '十億二千三百四十五万六千七百八十九'" do
        @src = '十億二千三百四十五万六千七百八十九'
        should == 10_2345_6789
      end
      it "should parse 千, 百, 十 without 一" do
        @src = "千百十一万千百十一"
        should == 1111_1111
      end
      it "should parse 一千" do
        @src = "一千百十一万一千百十一"
        should == 1111_1111
      end
      it "should parse ommission of four orders" do
        @src = "一億二千三百四十五"
        should == 1_0000_2345
      end
      it "should parse ommission of some orders" do
        @src = "一千二十万三百四"
        should == 1020_0304
      end
    end
  end

  describe ".normalize" do
    it %{should return "二十一万" for "廿壱萬"} do
      Kansuji.normalize("廿壱萬").should == "二十一万"
    end
    it %{should parse "廿壱萬"} do
      Kansuji.to_i("廿壱萬").should == 210000
    end
  end
end
