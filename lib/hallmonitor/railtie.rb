module Hallmonitor
  # Auto-instruments Rails ActionController actions to collect metrics
  # about their behavior
  class Railtie < Rails::Railtie
    config.after_initialize do
      if Hallmonitor.config.instrument_rails_controller_actions
        Hallmonitor::Railtie.enable_action_controller_metrics
      end
    end

    def self.enable_action_controller_metrics
      # See https://guides.rubyonrails.org/active_support_instrumentation.html#process-action-action-controller
      # for information on this notification
      ActiveSupport::Notifications.subscribe(/process_action.action_controller/) do |*args|
        begin
          event_args = parse_process_action_payload(args)

          tags = {
            controller: event_args[:controller],
            action: event_args[:action],
            status_code: event_args[:status]
          }

          Hallmonitor::TimedEvent.new(
            'controller.action.measure',
            duration: {
              total: event_args[:total_duration],
              database: event_args[:db_time],
              view: event_args[:view_time]
            },
            tags: tags
          ).emit

          Hallmonitor::Event.new('controller.action.count', tags: tags).emit
        rescue => ex
          Rails.logger.error("Caught error in Telemeter: #{ex.message}", ex)
        end
      end
    end

    # example args
    # ["process_action.action_controller",
    # 2013-11-22 11:17:04 -0600,
    # 2013-11-22 11:17:04 -0600,
    # "6a1302819619cb089922",
    # {:controller=>"BranchesController",
    #   :action=>"index",
    #   :params=>{"action"=>"index", "controller"=>"branches"},
    #   :format=>:html,
    #   :method=>"GET",
    #   :path=>"/branches",
    #   :status=>200,
    #   :view_runtime=>0.06999999999999999}]
    def self.parse_process_action_payload(args)
      parsed_arguments = {}
      rails_payload = args[4]

      parsed_arguments[:total_duration] = 1000.0 * (args[2] - args[1])
      parsed_arguments[:view_time] = rails_payload[:view_runtime] || 0
      parsed_arguments[:db_time] = rails_payload[:db_runtime] || 0
      parsed_arguments[:status] = rails_payload[:status]
      parsed_arguments[:controller] = rails_payload[:controller]
      parsed_arguments[:action] = rails_payload[:action]
      parsed_arguments[:format] = rails_payload[:format] || 'all'
      parsed_arguments[:format] = 'all' if parsed_arguments[:format] == '*/*'

      parsed_arguments
    end


  end
end
