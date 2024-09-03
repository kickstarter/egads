# frozen_string_literal: true

require_relative 'spec_helper'

describe Egads::Stage do
  subject { Egads::Stage }

  let(:sha) { 'abcdef123456' }
  let(:options) { { force: false, deployment_id: true } }
  let(:stage_instance) { subject.new([sha], options) }

  it 'should run the correct tasks' do
    expect(subject.commands.keys).to eq %w[setup_environment extract run_before_hooks bundle symlink_system_paths symlink_config_files run_after_stage_hooks mark_as_staged]
  end

  it 'should recognize the deployment_id class option' do
    expect(stage_instance.options[:deployment_id]).to eq true
  end

  it 'should correctly pass the deployment_id option to the stage method' do
    allow_any_instance_of(Egads::Stage).to receive(:stage).and_call_original
    expect(stage_instance.options[:deployment_id]).to eq(true)
  end
end
