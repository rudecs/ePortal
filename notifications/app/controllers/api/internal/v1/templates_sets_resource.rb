# frozen_string_literal: true

module API
  module Internal
    class V1::TemplatesSetsResource < V1 # API::Internal::V1
      # helpers API::V1::Helpers

      resource :templates_sets, desc: 'Набор шаблонов' do

        helpers do
          def templates_set_params
            declared_params[:templates_set]
          end
        end

        desc 'Index'
        params do
          optional :page, type: Integer, default: 1
          optional :per_page, type: Integer, default: 20
        end
        get jbuilder: 'templates_sets/index.json' do
          # TODO: search?
          @templates_sets = TemplatesSet.all
                                        .includes(:templates)
                                        .order(key_name: :asc)
                                        .page(params[:page]).per_page(params[:per_page])
        end

        desc 'Show'
        params do
          requires :id, type: Integer
        end
        get ':id', jbuilder: 'templates_sets/show.json' do
          @templates_set = TemplatesSet.find(params[:id])
        end

        desc 'Create'
        params do
          requires :templates_set, type: Hash do
            requires :key_name, type: String
            optional :category, type: String
            optional :templates_attributes, type: Array do
              optional :id, type: Integer # REVIEW: remove?
              optional :_destroy, type: Boolean
              requires :content, type: String
              requires :locale, type: String
              requires :delivery_method, type: String
              optional :subject, type: String
            end
          end
        end
        post jbuilder: 'templates_sets/show.json' do
          @templates_set = TemplatesSet.new(templates_set_params)
          error_422! @templates_set.errors unless @templates_set.save
        end

        desc 'Update'
        params do
          requires :templates_set, type: Hash do
            optional :key_name, type: String
            optional :category, type: String
            optional :templates_attributes, type: Array do
              optional :id, type: Integer
              optional :_destroy, type: Boolean
              optional :content, type: String
              optional :locale, type: String
              optional :delivery_method, type: String
              optional :subject, type: String
            end
          end
        end
        put ':id', jbuilder: 'templates_sets/show.json' do
          @templates_set = TemplatesSet.find(params[:id])
          error_422! @templates_set.errors unless @templates_set.update(templates_set_params)
        end

        desc 'Delete'
        params do
          requires :id, type: Integer
        end
        delete ':id' do
          TemplatesSet.find(params[:id]).destroy
        end
      end
    end
  end
end
