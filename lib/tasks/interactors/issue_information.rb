require 'hanami/interactor'

module Tasks
  module Interactors
    class IssueInformation
      include Hanami::Interactor

      expose :response

      def initialize(is_valid, **params)
        @params = params
        @is_valid = is_valid
      end

      def call
        @response = if @is_valid
          match_host(@params[:issue_url])
        else
          error('invalid params')
          EMPTY_URL_ERROR
        end
      end

    private

      EMPTY_URL_ERROR   = { error: 'empty url' }
      INVALID_URL_ERROR = { error: 'invalid url' }

      def match_host(issue_url)
        Container['tasks.matchers.git_host'].(issue_url) do |m|
          m.success(:github) { |issue_data| Container['tasks.services.github_issue_requester'].(issue_data) }
          m.success(:gitlab) { |issue_data| Container['tasks.services.gitlab_issue_requester'].(issue_data) }
          m.failure do
            error('invalid url')
            INVALID_URL_ERROR
          end
        end
      end
    end
  end
end
