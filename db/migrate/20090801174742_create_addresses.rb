class CreateAddresses < ActiveRecord::Migration
  def self.up
    create_table :addresses do |t|
      t.column :name, :string
      t.column :url, :string
      t.column :institution, :string
      t.column :street, :string
      t.column :city, :string
      t.column :state, :string
      t.column :postal_code, :string
      t.column :phone_number, :string
      t.timestamps
    end
  end

  def self.down
    drop_table :addresses
  end
end
