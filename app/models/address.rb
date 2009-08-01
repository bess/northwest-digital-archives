class Address < ActiveRecord::Base
  validates_presence_of [:name, :institution, :url, :state, :city, :postal_code, :phone_number], :message => 'is required'  
end
