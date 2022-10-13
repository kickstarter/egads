require_relative 'spec_helper'

describe Egads::S3Tarball do
  subject { Egads::S3Tarball.new('sha') }

  after { Aws.config.delete(:s3) }

  it('has a sha') { _(subject.sha).must_equal 'sha' }
  it('has a key') { _(subject.key).must_equal 'my_project/sha.tar.gz' }

  it "has an S3 bucket" do
    _(subject.bucket.name).must_equal Egads::Config.s3_bucket.name
  end

  it('should not exist') {
    Aws.config[:s3] = {stub_responses: { head_object: {status_code: 404, headers: {}, body: '', }}}
    _(subject.exists?).must_equal(false)
  }

  describe 'when uploaded' do
    before do
      subject.upload(ENV['EGADS_CONFIG'])
    end

    it('should exist') do
      _(subject.exists?).must_equal true
    end
  end
end
