require_relative 'spec_helper'

describe "Egads::Extract" do
  setup_configs!
  subject { Egads::Extract }

  it 'should run the correct tasks' do
  subject.commands.keys.must_equal %w(setup_environment download extract mark_as_extracted)
  end
end
