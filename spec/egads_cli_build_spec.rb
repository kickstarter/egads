require_relative 'spec_helper'

describe "Egads::CLI#build" do
  setup_configs!
  subject { Egads::CLI.new }

  it 'should build' do
    subject.build.must_equal true
  end
end
