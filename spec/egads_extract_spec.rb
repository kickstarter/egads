require_relative 'spec_helper'

describe "Egads::Extract" do
  subject { Egads::Extract }

  it 'should run the correct tasks' do
  _(subject.commands.keys).must_equal %w(setup_environment extract)
  end
end
