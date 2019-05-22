class AddAdditionalDescriptionFieldsToProducts < ActiveRecord::Migration[5.1]
  def change
    add_column :products, :additional_description_en, :string
    add_column :products, :additional_description_ru, :string
  end
end
