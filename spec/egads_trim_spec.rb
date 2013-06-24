require_relative 'spec_helper'

describe "Egads::Trim" do
  setup_configs!
  subject { Egads::Trim }

  it 'should run the correct tasks' do
  subject.commands.keys.must_equal %w(trim)
  end
end
