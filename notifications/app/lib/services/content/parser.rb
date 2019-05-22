# frozen_string_literal: true

module Services
  module Content
    class Parser
      attr_reader :user

      PERMITTED_OPERATIONS = /
        \{\{
        \s*
        (user\.(id|first_name|last_name|email|phone)|client\.(name|current_balance_cents|currency))
        \s*
        \}\}
      /x

      def initialize(user, client, content, options = {})
        @user = user
        @client = client
        @content = content
        @options = options
        @data = OpenStruct.new(@options[:operations])
      end

      # REVIEW: pure ruby code?
      def call
        @content.gsub(operations) do |command|
          cmd = '@' + command.tr('{} ', '')
          next if eval(cmd.split('.').first).nil? # soft replace
          eval(cmd)
        end
      end

      private

      def operations
        if @options[:operations].present?
          /\{\{\s*(user\.(id|first_name|last_name|email|phone)|client\.(name|current_balance_cents|currency)|data\.(#{@options[:operations].keys.join('|')}))\s*\}\}/x
        else
          PERMITTED_OPERATIONS
        end
      end
    end
  end
end
