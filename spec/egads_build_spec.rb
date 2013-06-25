require_relative 'spec_helper'

describe "Egads::Build" do
  setup_configs!
  subject { Egads::Build }

  it 'should run the correct tasks' do
    subject.commands.keys.must_equal %w(check_build make_git_archive append_revision_file run_after_build_hooks append_extra_paths gzip_archive upload)
  end

  it 'takes one argument' do
  	subject.arguments.size.must_equal 1
  end

  it 'has a rev argument' do
  	rev = subject.arguments.detect{|arg| arg.name == 'rev'}
  	rev.default.must_equal 'HEAD'
  	rev.required.must_equal false
  end

end

describe "Egags::Build instance" do
	subject { Egads::Build.new }
	
	it "has rev HEAD" do
		subject.rev.must_equal 'HEAD'
	end
end