# frozen_string_literal: true

module API
  class Internal::V1::DiscountPackagesResource < Internal::V1
    resource :discount_packages, desc: 'Наборы скидок' do

      helpers do
        def discount_package_params
          declared_params[:discount_package]
        end
      end

      desc 'Список наборов скидок'
      params do
        optional :page, type: Integer, default: 1
        optional :per_page, type: Integer, default: 20
      end
      get jbuilder: 'discount_packages/index.json' do
        @discount_packages = DiscountPackage.all
                                            .includes(discount_sets: :discount)
                                            .order(created_at: :desc)
                                            .page(params[:page]).per_page(params[:per_page])
      end

      desc 'Show'
      params do
        requires :id, type: Integer
      end
      get ':id', jbuilder: 'discount_packages/show.json' do
        @discount_package = DiscountPackage.find(params[:id])
      end

      desc 'Create'
      params do
        requires :discount_package, type: Hash do
          requires :name, type: String
          optional :discount_sets_attributes, type: Array do
            optional :id, type: Integer
            optional :_destroy, type: Boolean
            optional :amount, type: Float
            optional :amount_type, type: String
            optional :discount_id, type: Integer
            optional :discount_attributes, type: Hash do
              requires :key_name, type: String
            end
            exactly_one_of :discount_attributes, :discount_id
          end
        end
      end
      post jbuilder: 'discount_packages/show.json' do
        @discount_package = DiscountPackage.new(discount_package_params)
        error_422! @discount_package.errors unless @discount_package.save
      end

      desc 'Update'
      params do
        # requires :id, type: Integer
        requires :discount_package, type: Hash do
          optional :name, type: String
          optional :discount_sets_attributes, type: Array do
            optional :id, type: Integer
            optional :_destroy, type: Boolean
            optional :amount, type: Float
            optional :amount_type, type: String
            optional :discount_id, type: Integer # assign to existing. reassign to other discount
            optional :discount_attributes, type: Hash do # cannot change related discount. :id field inside is kinda useless.
              # optional :id, type: Integer
              requires :key_name, type: String
            end
            mutually_exclusive :discount_attributes, :discount_id
          end
        end
      end
      put ':id', jbuilder: 'discount_packages/show.json' do
        @discount_package = DiscountPackage.find(params[:id])
        error_422! @discount_package.errors unless @discount_package.update(discount_package_params)
      end

      desc 'Destroy'
      params do
        requires :id, type: Integer
      end
      delete ':id' do
        DiscountPackage.find(params[:id]).destroy
        # status :ok # :no_content?
      end
    end
  end
end
