require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "Dialy" do
  it "should find area codes" do
    Dialy::AREA_CODES[49].should be_include(221)
    Dialy::AREA_CODES[49].should be_include(2233)
    Dialy::AREA_CODES[49].should be_include(2235)
    Dialy::AREA_CODES[49].should be_include(2406)
    Dialy::AREA_CODES[49].should be_include(30)
    Dialy::AREA_CODES[49].should be_include(241)
    Dialy::AREA_CODES[49].should be_include(39291)
    Dialy::AREA_CODES[49].should be_include(163)
    
    Dialy::AREA_CODES[43].should be_include(1)
    
    Dialy::AREA_CODES[41].should be_include(44)
  end
  
  it "should calc min and max length" do
    Dialy::CC_RANGE.should == (1..3)
    Dialy::AC_RANGE[41].should == (2..3)
    Dialy::AC_RANGE[43].should == (1..4)
    Dialy::AC_RANGE[49].should == (2..5)
  end
  
  describe "options" do
    it "should use default_country_code" do
      Dialy::Config[:default_country_code] = 41
      Dialy::Number.new('030-12345678').to_s.should == '+41 30 12345678'
    end
  end
  
  describe "Germany" do
    before :each do
      Dialy::Config[:default_country_code] = 49
      @expected = '+49 2406 12345678'
    end
    
    it "should format plain number" do
      Dialy::Number.new('02406-12345678').to_s.should == @expected
    end
    
    it "should format with +49" do
      Dialy::Number.new('+49240612345678').to_s.should == @expected
    end
    
    it "should format with +49(0)" do
      Dialy::Number.new('+49(0)2406-123456-78').to_s.should == @expected
    end

    it "should format with 0049" do
      Dialy::Number.new('0049240612345678').to_s.should == @expected
    end
    
    it "should format with missing 0" do
      Dialy::Number.new('240612345678').to_s.should == @expected
    end
    
    it "should format german number in short format" do
      Dialy::Number.new('+49 2406 12345678').to_s(:short).should == '(02406) 12345678'
    end
    
    it "should format number from other country always in long format" do
      Dialy::Number.new('+41 71 1234567').to_s.should         == '+41 71 1234567'
      Dialy::Number.new('+41 71 1234567').to_s(:short).should == '+41 71 1234567'
    end
    
    it "should format non geographical numbers" do
      Dialy::Number.new('+49 3222 176 45 42').to_s.should == '+49 32 221764542'
    end
  end

  describe "German mobile" do
    before :each do
      Dialy::Config[:default_country_code] = 49
    end
    
    it "should format" do
      Dialy::Number.new('0163-1234567').to_s.should == '+49 163 1234567'
      Dialy::Number.new('0171-1234567').to_s.should == '+49 171 1234567'
    end
  end
  
  describe "obscure input" do
    before :each do
      Dialy::Config[:default_country_code] = 49
    end
    
    it "should format" do
      Dialy::Number.new('(+49) (08541) 123456').to_s.should == '+49 8541 123456'
      Dialy::Number.new('0 08 00-1 23 45 67').to_s.should == '+800 1234567'
      Dialy::Number.new('[0351] 1 23 45 6').to_s.should == '+49 351 123456'
    end
  end
  
  describe "Switzerland" do
    before :each do
      Dialy::Config[:default_country_code] = 41
    end
    
    it "should format" do
      Dialy::Number.new('0041-71-123 45 67').to_s.should == '+41 71 1234567'
      Dialy::Number.new('71-123 45 67').to_s.should == '+41 71 1234567'
    end
  end
  
  describe "Wrong formatting" do
    it "should fail with +" do
      lambda { Dialy::Number.new('++49') }.should raise_error(Dialy::WrongFormatting)
      lambda { Dialy::Number.new('0+49 221') }.should raise_error(Dialy::WrongFormatting)
    end
    
    it "should fail for non existing area_code" do
      lambda { Dialy::Number.new('+49 2396 1234567') }.should raise_error(Dialy::UnknownAreaCode)
    end
    
    it "should fail for non existing (+) country_code" do
      lambda { Dialy::Number.new('+429 1234 1234567') }.should raise_error(Dialy::UnknownCountryCode)
    end
    
    it "should fail for nun existing (00) country_code" do
      lambda { Dialy::Number.new('003834-123456') }.should raise_error(Dialy::UnknownCountryCode)
    end
  end
end