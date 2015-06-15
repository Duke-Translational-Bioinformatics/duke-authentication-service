class AddRedirectToConsumer < ActiveRecord::Migration
  def change
    add_column :consumers, :redirect_uri, :string
  end
end
