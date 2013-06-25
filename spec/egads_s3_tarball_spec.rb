require_relative 'spec_helper'

describe Egads::S3Tarball do
  setup_configs!

  before { ENV['EGADS_CONFIG'] = "example/egads.yml" }
  after { ENV.delete('EGAGS_CONFIG') }

  subject { Egads::S3Tarball.new('sha') }

  it('has a sha') { subject.sha.must_equal 'sha' }
  it('has a key') { subject.key.must_equal 'my_project/sha.tar.gz' }

  it "has an S3 bucket" do
    subject.bucket.must_equal Egads::Config.s3_bucket
  end

  it('should not exist') { subject.exists?.must_be_nil }

  describe 'when uploaded' do
    before do
      subject.upload(ENV['EGADS_CONFIG'])
    end

    it('should exist') { (!! subject.exists?).must_equal true }
  end


end

