class BlacklightToVersion20090127164750 < ActiveRecord::Migration
  def self.up
    Engines.plugins["blacklight"].migrate(20090127164750)
  end

  def self.down
    Engines.plugins["blacklight"].migrate(0)
  end
end
