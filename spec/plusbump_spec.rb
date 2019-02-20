require 'plusbump'

RSpec.configure do |config|
  config.before(:all) do 
    PlusBump::Tag.delete('Test_1.0.0')
  end
end

RSpec.describe PlusBump, "#bump" do
  context 'ref command used' do
    it 'should correctly increment minor to 0.1.0' do
      expect(PlusBump.bump_by_ref(ref: '5a3cba405f73778b487d56fad3fd4083cfb112b5')).to eq('0.1.0')
    end
    it 'should increment major from first commit' do
      expect(PlusBump.bump_by_ref(ref: 'e318c48368febb79309e7c371d99bb49fdd5f900')).to eq('1.0.0')
    end
  end
  
  context '--semver specifed in ref' do
    it 'should correctly increment minor so version becomes 1.1.0' do
      expect(PlusBump.bump_by_ref(ref: '5a3cba405f73778b487d56fad3fd4083cfb112b5', semver: '1.0.0')).to eq('1.1.0')
    end
    it 'should correctly increment major so version becomes 2.0.0' do
      expect(PlusBump.bump_by_ref(ref: 'e318c48368febb79309e7c371d99bb49fdd5f900', semver: '1.0.0')).to eq('2.0.0')
    end
    it 'should correctly increment major so new semver v2.0.0' do
      expect(PlusBump.bump_by_ref(ref: 'e318c48368febb79309e7c371d99bb49fdd5f900', semver: 'v1.0.0')).to eq('v2.0.0')
    end
  end

  context '--semver and --prefix specified in ref' do
    it 'should correctly increment major so new semver v2.0.0 with manually added prefix' do
      expect(PlusBump.bump_by_ref(ref: 'e318c48368febb79309e7c371d99bb49fdd5f900', semver: '1.0.0', prefix: 'v')).to eq('v2.0.0')
    end
  end

  context 'tag command used' do
    it 'should increment to major when used against 0.1.* and not be 0.1.0' do
      expect(PlusBump.bump_by_tag(latest: '0.1.')).not_to eq('0.1.0')
    end
    it 'should increment to major when used against 0.1.*' do
      expect(PlusBump.bump_by_tag(latest: '0.1.')).to eq('1.0.0')
    end
    it 'should increment to 1.0.0 when no tag found' do
      expect(PlusBump.bump_by_tag(latest: 'not_found')).to eq('1.0.0')
    end
    it 'should incremment to 3.0.0 when semver is prefix' do
      expect(PlusBump.bump_by_tag(latest: '[0-9]')).to eq('3.0.0')
    end
  end

  context 'tag command used with --prefix switch' do
    it 'should incremment to 3.0.0 when semver is prefix, and append prefix if specifed' do
      expect(PlusBump.bump_by_tag(latest: '[0-9]', prefix: 'Test_')).to eq('Test_3.0.0')
    end
    it 'should increment to correctly with tag prefix' do
      expect(PlusBump.bump_by_tag(latest: 'R_', prefix: 'Test_')).to eq('Test_2.1.0')
    end
  end

  context 'tag should be created' do
    specify { expect { PlusBump::Tag.create('Test_1.0.0') }.to output(/Created tag Test_1.0.0/).to_stdout }
  end

  context 'console response behaviour' do
      specify { expect { puts PlusBump.bump_by_tag(latest: 'R_', prefix: 'R_') }.to output(/R_2.1.0/).to_stdout }
      specify { expect { puts PlusBump.bump_by_tag(latest: 'R_') }.to output(/2.1.0/).to_stdout }
      specify { expect { PlusBump.bump_by_tag(latest: 'not_found') }.to output(/No matching tag found for not_found/).to_stdout }
      specify { expect(`ruby bin/plusbump -blaha`).to match(/Usage:/) }
  end

end
