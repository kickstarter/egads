require_relative 'spec_helper'

describe "Egads::Stage" do
  subject { Egads::Stage }

  it 'should run the correct tasks' do
  subject.commands.keys.must_equal %w(setup_environment extract run_before_hooks bundle symlink_system_paths symlink_config_files run_after_stage_hooks mark_as_staged)
  end
end
