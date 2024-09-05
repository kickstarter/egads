# frozen_string_literal: true

require_relative 'spec_helper'

describe 'Egads::Stage' do
  subject { Egads::Stage }

  it 'should run the correct tasks' do
    _(subject.commands.keys).must_equal %w[setup_environment extract run_before_hooks bundle symlink_system_paths symlink_config_files run_after_stage_hooks mark_as_staged]
  end

  # it 'should have the correct class options' do
  #   expected_options = {
  #     force: { type: :boolean, default: false, banner: 'Overwrite existing files' },
  #     deployment_id: { type: :boolean, default: false, banner: 'Include deployment ID in release directory'}
  #   }

  #   actual_options = subject.class_options.transform_values { |opt| { type: opt.type, default: opt.default, banner: opt.banner }}
  #   _(actual_options).must_equal expected_options
  # end
end
