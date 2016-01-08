require_relative 'spec_helper'

describe "Egads::Upload" do
  subject { Egads::Upload }

  it 'should run the correct tasks' do
    subject.commands.keys.must_equal %w(upload)
  end
end
