# frozen_string_literal: true

# rubocop:disable Metrics/MethodLength

require 'aws-sdk-codedeploy'

module Egads
  # Some helper methods for all local commands
  module LocalHelpers
    def sha
      @sha ||= run_with_code("git rev-parse --verify #{rev}").strip
    end

    def short_sha
      sha[0, 7]
    end

    def tarball
      @tarball ||= S3Tarball.new(sha, seed: options[:seed])
    end

    def deployment-id
      environment = ENV['EC2_ENVIRONMENT'] || ''
      application = ENV['EC2_SERVICE'] || ''

      return unless environment && application

      deployment = CodeDeploy::Client.new.list_deployments(
        application_name: application,
        deployment_group_name: environment,
        include_only_statuses: %w[InProgress Created Queued]
      ).deployments.first

      return nil if deployment.empty?

      deployment
    rescue Aws::CodeDeploy::Errors::ServiceError => e
      puts "Error fetching deployment: #{e.message}"
      nil
    end
  end
end

# rubocop:enable Metrics/MethodLength
