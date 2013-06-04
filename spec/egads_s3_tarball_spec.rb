require_relative 'spec_helper'

describe Egads::S3Tarball do

  before { ENV['EGADS_CONFIG'] = "spec/egads.yml" }
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
      Egads::Config.s3_bucket.save # Ensure bucket exists
      subject.upload(ENV['EGADS_CONFIG'])
    end

    it('should exist') { subject.exists?.wont_be_nil }
    it('should have a url') { subject.url.must_be_kind_of String }
  end


end

