require_relative 'spec_helper'

describe "Egads::Build" do
  setup_configs!
  subject { Egads::Build }

  it 'should run the correct tasks' do
    subject.commands.keys.must_equal %w(check_build make_git_archive append_revision_file run_after_build_hooks append_extra_paths gzip_archive upload)
  end
end
