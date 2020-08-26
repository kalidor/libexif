EXPECTED_RESULTS = {
  "tests/sample.tiff" => {
    "endianess" => :little,
    "ifd0" => {
      "ImageWidth" => 1728,
      "ImageHeight" => 2376,
      "BitsPerSample" => 1,
      "Compression" => "T6/Group 4 Fax",
      "PhotometricInterpretation" => 0,
      "ImageDescription" => "converted PBM file",
      "PreviewImageStart" => 8,
      "Orientation" => "Horizontal",
      "SamplesPerPixel" => 1,
      "RowsPerStrip" => 2376,
      "PreviewImageLength" => 10812,
      "XResolution" => "200.00 (200)",
      "YResolution" => "200.00 (200)",
      "PlanarConfiguration" => "Chunky",
      "ResolutionUnit" => "Inches",
    }
  },
  "tests/lena_std.tiff" => {
    "endianess" => :big,
    "ifd0" => {
      "ImageWidth" => 512,
      "ImageHeight" => 512,
      "BitsPerSample" => 12,
      "Compression" =>"Uncompressed",
      "PhotometricInterpretation" => 2,
      "PreviewImageStart" => 8,
      "SamplesPerPixel" => 3,
      "PreviewImageLength" => 786432,
      "PlanarConfiguration" => "Chunky"
    }
  },
  "tests/IMG_3529.jpg" => {
    "endianess" => :little,
    "ifd0" => {
      "Make" => "Canon",
      "Model" => "Canon EOS 60D",
      "XResolution" => "240.00 (240)",
      "YResolution" => "240.00 (240)",
      "ResolutionUnit" => "Inches",
      "Software" => "Adobe Photoshop Lightroom 5.0 (Macintosh)",
      "ModifyDate" => "2015:04:25 21:51:28",
      "Artist" => "Gregory Charbonneau",
      "Copyright" => "2009-2013 - Some rights reserved",
      "ExifOffset" => 286
    }
  }
}
