require_relative 'spec_helper'

describe Egads::Config do

  subject { Egads::Config }
  it "raises ArgumentError for missing config" do
    -> { subject.config_path }.must_raise(ArgumentError)
  end

  describe "with an config file" do
    before { ENV['EGADS_CONFIG'] = "example/egads.yml" }
    after { ENV.delete('EGAGS_CONFIG') }

    it "has an S3 bucket" do
      subject.s3_bucket.key.must_equal 'my-bucket'
    end

    it "has an S3 prefix" do
      subject.s3_prefix.must_equal 'my_project'
    end
  end

end
