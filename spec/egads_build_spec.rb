require_relative 'spec_helper'

describe "Egads::Build" do
  subject { Egads::Build }

  it 'should run the correct tasks' do
    _(subject.commands.keys).must_equal %w(check_build run_before_build_hooks write_revision_file commit_extra_paths make_tarball run_after_build_hooks upload)
  end

  it 'takes one argument' do
    _(subject.arguments.size).must_equal 1
  end

  it 'has a rev argument' do
    rev = subject.arguments.detect{|arg| arg.name == 'rev'}
    _(rev.default).must_equal 'HEAD'
    _(rev.required).must_equal false
  end

  it "exits on failure" do
    _(subject.exit_on_failure?).must_equal true
  end
end

describe "Egags::Build instance" do
  subject { Egads::Build.new }

  it "has rev HEAD" do
    _(subject.rev).must_equal 'HEAD'
  end
end
