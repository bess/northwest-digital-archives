$: << File.dirname(__FILE__) unless $:.include?(File.dirname(__FILE__))

module NWDA
  
  autoload :Mappers, 'nwda/mappers.rb'
  
end