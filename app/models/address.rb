class Address < ActiveRecord::Base
  validates_presence_of :name, :message => 'is required'
  validates_presence_of :url, :message => 'is required'
end
