require_relative 'spec_helper'

describe "Egads::Extract" do
  setup_configs!
  subject { Egads::Extract }

  it 'should run the correct tasks' do
  subject.commands.keys.must_equal %w(setup_environment extract)
  end
end
