class AddEndnoteSupport < ActiveRecord::Migration
  def self.up
    # Additional columns for Book information
    add_column :abstracts, :editors, :string
    add_column :abstracts, :publisher, :string
    add_column :abstracts, :publisher_location, :string
    
    add_column :abstracts, :source, :string
    add_column :abstracts, :source_id, :string
  end

  def self.down
    remove_column :abstracts, :editors
    remove_column :abstracts, :publisher
    remove_column :abstracts, :publisher_location
    remove_column :abstracts, :source
    remove_column :abstracts, :source_id
  end
end