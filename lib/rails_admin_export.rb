module RailsAdmin
  module Config
    module Actions
      #
      class Export < RailsAdmin::Config::Actions::Base
        RailsAdmin::Config::Actions.register(self)

        register_instance_option :collection do
          true
        end

        register_instance_option :http_methods do
          [:get, :post]
        end

        register_instance_option :controller do
          proc do
            format = params[:csv] && :csv
            if format
              request.format = format
              # @schema = params[:schema].symbolize if params[:schema]
              # to_json and to_xml expect symbols for keys AND values.
              @objects = list_entries(@model_config, :export)
              send_data @objects.to_csv, filename: "#{@abstract_model.to_s.pluralize}.csv", type: 'text/csv'
              # index
            else
              render @action.template_name
            end
          end
        end

        register_instance_option :bulkable? do
          true
        end

        register_instance_option :link_icon do
          'icon-share'
        end
      end
    end
  end
end
