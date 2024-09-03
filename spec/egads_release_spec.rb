# frozen_string_literal: true

require_relative 'spec_helper'

describe Egads::Release do
  subject { Egads::Release }

  let(:sha) { 'abcdef123456' }
  let(:options) { { force: false, deployment_id: true } }
  let(:release_instance) { subject.new([sha], options) }

  it 'should run the correct tasks' do
    expect(subject.commands.keys).to eq %w(setup_environment stage run_before_release_hooks symlink_release restart run_after_release_hooks trim)
  end

  it 'should recognize the deployment_id class option' do
    expect(release_instance.options[:deployment_id]).to eq true
  end

  it 'should correctly pass the deployment_id option to the stage method' do
    allow_any_instance_of(Egads::Stage).to receive(:stage).and_call_original
    expect(release_instance.options[:deployment_id]).to eq(true)
  end
end
