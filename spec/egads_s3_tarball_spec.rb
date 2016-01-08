require_relative 'spec_helper'

describe Egads::S3Tarball do
  subject { Egads::S3Tarball.new('sha') }

  it('has a sha') { subject.sha.must_equal 'sha' }
  it('has a key') { subject.key.must_equal 'my_project/sha.tar.gz' }

  it "has an S3 bucket" do
    subject.bucket.must_equal Egads::Config.s3_bucket
  end

  it('should not exist') {
    skip 'Weird stubbing issues with Resource#exists?'
    Aws.config[:s3] = {stub_responses: { head_object: 'NotFound' }}
    subject.exists?.must_equal(false)
  }

  describe 'when uploaded' do
    before do
      subject.upload(ENV['EGADS_CONFIG'])
    end

    it('should exist') do
      skip 'Weird stubbing issues with Resource#exists?'
      subject.exists?.must_equal true
    end
  end
end

