require 'plusbump'

RSpec.describe PlusBump, "#bump" do
  specify { 
    expect { PlusBump.bump(nil, "not_found") }.to output(/No matching tag found for not_found/).to_stdout 
  }
  context "self smoke test" do
      it "should correctly increment minor to 0.1.0" do
        expect(PlusBump.bump("5a3cba405f73778b487d56fad3fd4083cfb112b5", nil)).to eq("0.1.0")
      end
      it "should increment major from first commit" do 
        expect(PlusBump.bump("e318c48368febb79309e7c371d99bb49fdd5f900", nil)).to eq("1.0.0")
      end
      it "should increment to major when used against 0.1.*" do
        expect(PlusBump.bump(nil, "0.1.")).not_to eq("0.1.0")
      end
      it "should increment to 1.0.0 when no tag found" do
        expect(PlusBump.bump(nil, "not_found")).to eq("1.0.0")
      end  
  end 
end