class CreateConsumers < ActiveRecord::Migration
  def change
    create_table :consumers do |t|
      t.string :uuid
      t.string :secret

      t.timestamps null: false
    end
  end
end
