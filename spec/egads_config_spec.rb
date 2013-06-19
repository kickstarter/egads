require_relative 'spec_helper'

describe Egads::Config do

  subject { Egads::Config }
  it "raises ArgumentError for missing config" do
    -> { subject.config_path }.must_raise(ArgumentError)
  end

  describe "with an config file" do
    setup_configs!

    let(:yml) { YAML.load_file("example/egads.yml") }

    describe '#config' do
      it 'is a hash' do
        subject.config.must_equal yml
      end
    end

    it "has an S3 bucket" do
      subject.s3_bucket.key.must_equal yml['s3']['bucket']
    end

    it "has an S3 prefix" do
      subject.s3_prefix.must_equal yml['s3']['prefix']
    end
  end

end

describe Egads::RemoteConfig do
  subject { Egads::RemoteConfig }

  it "raises ArgumentError for missing config" do
    -> { subject.config_path }.must_raise(ArgumentError)
  end

  describe "with an config file" do
    setup_configs!
    let(:yml) { YAML.load_file("example/egads_remote.yml") }

    describe '#config' do
      it('is a hash') { subject.config.must_equal yml }
    end

    it('#release_to') { subject.release_to.must_equal yml['release_to'] }
    it('#extract_to') { subject.extract_to.must_equal yml['extract_to'] }
    it('#release_dir') { subject.release_dir('abc').must_equal File.join(yml['extract_to'], 'abc') }
    it('#restart_command') { subject.restart_command.must_equal yml['restart_command'] }

    describe '#setup_environment' do
      before { subject.setup_environment }
      after do
        # Delete ENV from yaml data
        yml['env'].keys.each{|key| ENV.delete(key) }
      end

      it 'should set ENV values' do
        yml['env'].each do |key, value|
          ENV[key].must_equal value
        end
      end
    end

  end
end
