require 'plusbump'
require 'docopt'

RSpec.configure do |config|
  config.before(:all) do
    PlusBump::Tag.delete('Test_1.0.0')
  end
end

def build_input(commandline)
  Docopt.docopt(PlusBump::DOCOPT, version: PlusBump::VERSION, argv: commandline.split(' '))
end

RSpec.describe PlusBump, "bump" do
  context '--from-ref used' do
    it 'should correctly increment minor to 0.1.0' do
      input = build_input("--from-ref 5a3cba405f73778b487d56fad3fd4083cfb112b5 --base-version 0.0.0")
      expect(PlusBump.bump(input)).to eq('0.1.0')
    end
    it 'should increment major from to 1.0.0' do
      input = build_input("--from-ref e318c48368febb79309e7c371d99bb49fdd5f900 --base-version 0.0.0")
      expect(PlusBump.bump(input)).to eq('1.0.0')
    end
  end

  context '--base-version used with --from-ref' do
    it 'should correctly increment minor so version becomes 1.1.0' do
      input = build_input("--from-ref 5a3cba405f73778b487d56fad3fd4083cfb112b5 --base-version 1.0.0")
      expect(PlusBump.bump(input)).to eq('1.1.0')
    end
    it 'should correctly increment major so version becomes 2.0.0' do
      input = build_input("--from-ref e318c48368febb79309e7c371d99bb49fdd5f900 --base-version 1.0.0")
      expect(PlusBump.bump(input)).to eq('2.0.0')
    end
  end

#  context '--semver and --prefix specified in ref' do
#    it 'should correctly increment major so new semver v2.0.0 with manually added prefix' do
#      expect(PlusBump.bump_by_ref(ref: 'e318c48368febb79309e7c371d99bb49fdd5f900', semver: '1.0.0', prefix: 'v')).to eq('v2.0.0')
#    end
#  end

  context '--from-tag with --base-version' do
    it 'should increment to major when used against 0.1.* and not be 0.1.0' do
      input = build_input("--from-tag 0.1. --base-version 0.0.0")
      expect(PlusBump.bump(input)).not_to eq('0.1.0')
    end
    it 'should increment to major when used against 0.1.*' do
      input = build_input("--from-tag 0.1. --base-version 0.0.0")
      expect(PlusBump.bump(input)).not_to eq('0.1.0')
      expect(PlusBump.bump(input)).to eq('1.0.0')
    end
  end

  context '--from-tag with with --base-version-from-tag' do
    it 'should increment to 3.0.0 when used with 2.0.0 as tag glob' do
      input = build_input("--from-tag 2.0.0 --base-version-from-tag='' --new-prefix=Test_")
      expect(PlusBump.bump(input)).to eq('Test_3.0.0')
    end
    it 'should increment to 2.1.0 when used with 2.0.0 as tag glob and no matching major pattern (minor matches)' do
      input = build_input("--from-tag 2.0.0 --base-version-from-tag='' --new-prefix=Test_ --major-pattern=not_there")
      expect(PlusBump.bump(input)).to eq('Test_2.1.0')
    end
    it 'should increment to correctly with tag prefix' do
      input = build_input("--from-tag R_ --base-version-from-tag=R_")
      expect(PlusBump.bump(input)).to eq('2.1.0')
    end
    it 'should increment correctly with empty base-version-from-tag' do
      input = build_input("--from-tag R_ --base-version-from-tag=''")
      expect(PlusBump.bump(input)).to eq('2.1.0')
    end
  end

  context 'tag should be created' do
    specify { expect { PlusBump::Tag.create('Test_1.0.0') }.to output(/Created tag Test_1.0.0/).to_stdout }
  end

end
