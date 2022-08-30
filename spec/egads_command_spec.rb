require_relative 'spec_helper'

describe "Egads::Command" do
  subject { Egads::Command }
  it 'should exit on failure' do
    _(subject.exit_on_failure?).must_equal true
  end
end
