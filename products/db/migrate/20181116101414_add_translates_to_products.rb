class AddTranslatesToProducts < ActiveRecord::Migration[5.1]
  def change
    if column_exists? :products, :name
      rename_column :products, :name, :name_ru
    end

    unless column_exists? :products, :name_en
      add_column :products, :name_en, :string
    end

    if column_exists? :products, :description
      rename_column :products, :description, :description_ru
    end

    unless column_exists? :products, :description_en
      add_column :products, :description_en, :string
    end
  end
end
