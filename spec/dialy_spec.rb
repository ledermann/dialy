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
      Dialy.format('030-12345678').should == '+41 30 12345678'
    end
  end
  
  describe "Germany" do
    before :each do
      Dialy::Config[:default_country_code] = 49
      @expected = '+49 2406 12345678'
    end
    
    it "should format plain number" do
      Dialy.format('02406-12345678').should == @expected
    end
    
    it "should format with +49" do
      Dialy.format('+49240612345678').should == @expected
    end
    
    it "should format with +49(0)" do
      Dialy.format('+49(0)2406-123456-78').should == @expected
    end

    it "should format with 0049" do
      Dialy.format('0049240612345678').should == @expected
    end
    
    it "should format with missing 0" do
      Dialy.format('240612345678').should == @expected
    end
  end

  describe "German mobile" do
    before :each do
      Dialy::Config[:default_country_code] = 49
    end
    
    it "should format" do
      Dialy.format('0163-1234567').should == '+49 163 1234567'
      Dialy.format('0171-1234567').should == '+49 171 1234567'
    end
  end
  
  describe "obscure input" do
    before :each do
      Dialy::Config[:default_country_code] = 49
    end
    
    it "should format" do
      Dialy.format('(+49) (08541) 123456').should == '+49 8541 123456'
      Dialy.format('0 08 00-1 23 45 67').should == '+800 1234567'
      Dialy.format('[0351] 1 23 45 6').should == '+49 351 123456'
    end
  end
  
  describe "Switzerland" do
    before :each do
      Dialy::Config[:default_country_code] = 41
    end
    
    it "should format" do
      Dialy.format('0041-71-123 45 67').should == '+41 71 1234567'
      Dialy.format('71-123 45 67').should == '+41 71 1234567'
    end
  end
  
  describe "Wrong formatting" do
    it "should fail with +" do
      lambda { Dialy.format('++49') }.should raise_error(Dialy::WrongFormatting)
      lambda { Dialy.format('0+49 221') }.should raise_error(Dialy::WrongFormatting)
    end
    
    it "should fail for non existing area_code" do
      lambda { Dialy.format('+49 2396 1234567') }.should raise_error(Dialy::UnknownAreaCode)
    end
    
    it "should fail for non existing country_code" do
      lambda { Dialy.format('+429 1234 1234567') }.should raise_error(Dialy::UnknownCountryCode)
    end
  end
  
  describe "error correction" do
    before :each do
      Dialy::Config[:default_country_code] = 49
    end
    
    it "should format for invalid 00" do
      Dialy.format('003834-831708').should == '+49 3834 831708'
      #Dialy.format('00201-123456').should == '+49 0201 123456'
    end
  end
end