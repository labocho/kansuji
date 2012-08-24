# encoding: UTF-8
require "spec_helper"
require "ruby-debug"

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
        @src = "千二十万三百四"
        should == 1020_0304
      end
      it "shoud ignore leading spaces" do
        @src = " \t\n\r\n二百五十六"
        should == 256
      end
      it "shoud ignore following characters" do
        @src = "二百五十六人"
        should == 256
      end
      it "shoud ignore following characters include kansuji" do
        @src = "二百五十六円二十五銭"
        should == 256
      end
    end
  end

  describe ".to_arabic" do
    it "should convert kansuji to arabic" do
      pending
      @src = "10000 USDは七万八千六百九十円五十八銭"
      Kansuji.to_arabic(@src).should == "10000 USDは78690円58銭"
    end
    it "should convert kansuji to arabic" do
      pending
      @src = "10000 USDは七万八千六百九十円五十八銭"
      Kansuji.to_arabic(@src, :mixed).should == "10000 USDは7万8690円58銭"
    end
  end

  describe ".to_kansuji" do
    context "type: replace" do
      subject { Kansuji.to_kansuji(@src, :replace) }
      it "should return '一〇二三四五六七八九' for 1023456789" do
        @src = 10_2345_6789
        should == "一〇二三四五六七八九"
      end
    end
    context "type: mixed" do
      subject { Kansuji.to_kansuji(@src, :mixed) }
      it "should build '一〇億二三四五万六七八九'" do
        @src = 10_2345_6789
        should == "一〇億二三四五万六七八九"
      end
      it "should ommit four orders" do
        @src = 1_0000_2345
        should == "一億二三四五"
      end
    end
    context "type: mixed_arabic" do
      subject { Kansuji.to_kansuji(@src, :mixed_arabic) }
      it "should build '10億2345万6789" do
        @src = 10_2345_6789
        should == "10億2345万6789"
      end
      it "should build max order" do
        @src = 1_2345_6789_0123_4567_8901_2345_6789_0123_4567_8901_2345_6789_0123_4567_8901_2345_6789
        should == "1無量大数2345不可思議6789那由他0123阿僧祇4567恒河沙8901極2345載6789正0123澗4567溝8901穣2345𥝱6789垓0123京4567兆8901億2345万6789"
      end
    end
    context "type: traditional" do
      subject { Kansuji.to_kansuji(@src, :traditional) }
      it "should build '十億二千三百四十五万六千七百八十九'" do
        @src = 10_2345_6789
        should == '十億二千三百四十五万六千七百八十九'
      end
      it "should build 千, 百, 十 without 一" do
        @src = 1111_1111
        should == "千百十一万千百十一"
      end
      it "should build 一千" do
        pending
        @src = 1111_1111
        should == "一千百十一万一千百十一"
      end
      it "should omit four orders" do
        @src = 1_0000_2345
        should == "一億二千三百四十五"
      end
      it "should omit some orders" do
        @src = 1020_0304
        should == "千二十万三百四"
      end
    end
    context "call with string" do
      it "should convert arabic to kansuji" do
        pending
        @src = "10000 USDは78690円58銭"
        Kansuji.to_kansuji(@src).should == "10000 USDは七万八千六百九十円五十八銭"
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
