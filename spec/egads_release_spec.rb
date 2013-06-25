require_relative 'spec_helper'

describe "Egads::Release" do
  setup_configs!
  subject { Egads::Release }

  it 'should run the correct tasks' do
  subject.commands.keys.must_equal %w(setup_environment stage run_before_release_hooks symlink_release restart run_after_release_hooks trim)
  end
end
