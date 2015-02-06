require_relative '../libexif'
require 'spec_helper'

describe REXIF do
  before :all do
    @files = ["tests/IMG_2857.CR2", "tests/IMG_8394.CR2", "tests/P1070309.JPG"]

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
      it "default is disabled" do
        img = REXIF::IMG.new("tests/IMG_2857.CR2")
        img.verbose.should == false
      end
    end
    context "generic instance variables: verbose" do
      it "Enabled is asked for" do
        img = REXIF::IMG.new("tests/IMG_2857.CR2", true)
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
    end
    context "Unknown method" do
      it "throws a NoMethodError if user call undefined method" do
        lambda{@data[@files[0]].analyze; @data[@files[0]].cannot_be_call}.should raise_exception(NoMethodError)
      end
    end
  end

  describe "Regression tests" do
    context "CR2 from Canon 60D" do
      it "exif data" do
        @data[@files[0]].analyze()
        EXPECTED_RESULTS[@files[0]]["exif"].map{|k, v|
          @data[@files[0]].exif.send(k).should eql v
        }
      end
      it "ifd0/ifd1/ifd2/ifd3 data" do
        @data[@files[0]].analyze()
        0.upto(3).map{|id|
          EXPECTED_RESULTS[@files[0]]["ifd%d" % id].map{|k, v|
            @data[@files[0]].instance_variable_get("@ifd%d" % id).send(k).should eql v
          }
        }
      end
    end
    context "CR2 from Canon 6D" do
      it "exif data" do
        @data[@files[1]].analyze()
        EXPECTED_RESULTS[@files[1]]["exif"].map{|k, v|
          @data[@files[1]].exif.send(k).should eql v
        }
      end
      it "ifd0/ifd1/ifd2/ifd3 data" do
        @data[@files[1]].analyze()
        0.upto(3).map{|id|
          EXPECTED_RESULTS[@files[1]]["ifd%d" % id].map{|k, v|
            @data[@files[1]].instance_variable_get("@ifd%d" % id).send(k).should eql v
          }
        }
      end
      it "gps data" do
        @data[@files[1]].analyze()
        EXPECTED_RESULTS[@files[1]]["gps"].map{|k, v|
          @data[@files[1]].gps.send(k).should eql v
        }
      end
    end
    context "JPEG from Panasonic" do
      it "exif data" do
        @data[@files[2]].analyze()
        EXPECTED_RESULTS[@files[2]]["exif"].map{|k, v|
          @data[@files[2]].exif.send(k).should eql v
        }
      end
      it "ifd0/ifd1" do
        @data[@files[2]].analyze()
        0.upto(1).map{|id|
          EXPECTED_RESULTS[@files[2]]["ifd%d" % id].map{|k, v|
            @data[@files[2]].instance_variable_get("@ifd%d" % id).send(k).should eql v
          }
        }
      end
    end
  end
end

