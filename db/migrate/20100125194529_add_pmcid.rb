class AddPmcid < ActiveRecord::Migration
  def self.up
    add_column :abstracts, :pmcid, :string
  end

  def self.down
    remove_column :abstracts, :pmcid, :string
  end
end