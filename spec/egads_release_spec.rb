# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Egads::Release' do
  subject { Egads::Release }

  it 'should run the correct tasks' do
    _(subject.commands.keys).must_equal %w[setup_environment stage run_before_release_hooks symlink_release restart run_after_release_hooks trim]
  end

  # it 'should have the correct class options' do
  #   expected_options = {
  #     force: { type: :boolean, default: false, banner: 'Overwrite existing release' },
  #     deployment_id: { type: :boolean, default: false, banner: 'Include deployment ID in release directory' }
  #   }

  #   actual_options = subject.class_options.transform_values { |opt| { type: opt.type, default: opt.default, banner: opt.banner }}
  #   _(actual_options).must_equal expected_options
  # end
end
