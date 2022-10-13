require_relative 'spec_helper'

describe Egads::Config do

  subject { Egads::Config }
  it "raises ArgumentError for missing config" do
    ENV['EGADS_CONFIG'] = '/no/such/path'
    _{ subject.config_path }.must_raise(ArgumentError)
  end

  describe "with an config file" do

    let(:yml) { YAML.load_file("example/egads.yml") }

    describe '#config' do
      it 'is a hash' do
        _(subject.config).must_equal yml
      end
    end

    it "has an S3 bucket" do
      _(subject.s3_bucket.name).must_equal yml['s3']['bucket']
    end

    it "has an S3 prefix" do
      _(subject.s3_prefix).must_equal yml['s3']['prefix']
    end
  end

end

describe Egads::RemoteConfig do
  subject { Egads::RemoteConfig }

  it "raises ArgumentError for missing config" do
    ENV['EGADS_REMOTE_CONFIG'] = '/no/such/path'
    _{ subject.config_path }.must_raise(ArgumentError)
  end

  describe "with an config file" do
    let(:yml) { YAML.load_file("example/egads_remote.yml") }

    describe '#config' do
      it('is a hash') { _(subject.config).must_equal yml }
    end

    it('#release_to') { _(subject.release_to).must_equal yml['release_to'] }
    it('#extract_to') { _(subject.extract_to).must_equal yml['extract_to'] }
    it('#release_dir') { _(subject.release_dir('abc')).must_equal File.join(yml['extract_to'], 'abc') }
    it('#restart_command') { _(subject.restart_command).must_equal yml['restart_command'] }
    it('#bundler_options') { _(subject.bundler_options).must_equal yml['bundler']['options'] }

    describe '#setup_environment' do
      before { subject.setup_environment }
      after do
        # Delete ENV from yaml data
        yml['env'].keys.each{|key| ENV.delete(key) }
      end

      it 'should set ENV values' do
        yml['env'].each do |key, value|
          _(ENV[key]).must_equal value
        end
      end
    end

  end
end
