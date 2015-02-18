require_relative '../libexif'
require 'spec_helper'

describe REXIF do
  before :all do
    @files = ["tests/lena_std.tiff", "tests/sample.tiff"]

  end
  before :each do
    @data = Hash[@files.map{|f| [f, REXIF::IMG.new(f, false)]}]
  end

  describe "#new" do
    context "with parameter" do
      it "returns a new REXIF::IMG object" do
        @data.map{|f, img| img.should(be_an_instance_of(REXIF::IMG))}
      end
    end
    context "with no parameter" do
      it "throws an ArgumentError when called without argument" do
        lambda{REXIF::IMG.new()}.should(raise_exception(ArgumentError))
      end
    end

    context "generic instance variables: verbose" do
      it "Disabled if not specified" do
        img = REXIF::IMG.new(@files.first)
        img.verbose.should == false
      end
      it "Enabled if specified" do
        img = REXIF::IMG.new(@files.first, true)
        img.verbose.should == true
      end
    end
    context "filename" do
      it "Filename is stocked" do
        @data.map{|f, img| img.filename.should eql f}
      end
    end
  end

  describe "#analyze" do
    context "Reading the file" do
      it "Endianess is detected" do
        @data.map{|f, img|
          img.analyze()
          img.endianess.should eql EXPECTED_RESULTS[f]["endianess"]
        }
      end
      it "Defined variables" do
        @data.map{|f, img|
          img.analyze()
          img.infos.should == [:ifd0?]
        }
      end
      it "ifd0? well defined (default: false, available: true)" do
        @data.map{|f, img|
          img.analyze()
          img.ifd0?.should == true
        }
      end
    end
    context "Unknown method" do
      it "throws a NoMethodError if user call undefined method" do
        lambda{@data[@files[0]].analyze; @data[@files[0]].cannot_be_call}.should raise_exception(NoMethodError)
      end
    end
  end

  describe "Regression tests" do
    context "TIFF files" do
      it "ifd0 data" do
        @files.map{ |f|
          @data[f].analyze()
          EXPECTED_RESULTS[f]["ifd0"].map{|k, v|
            @data[f].ifd0.send(k).should eql v
          }
        }
      end
    end
  end
end

