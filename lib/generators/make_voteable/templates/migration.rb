class CreateMakeVoteableTables < ActiveRecord::Migration
   def self.up
     create_table :votings do |t|
       t.string :voteable_type
       t.integer :voteable_id
       t.string :voter_type
       t.integer :voter_id
       t.boolean :up_vote, :null => false

       t.timestamps
    end

    add_index :votings, [:voteable_type, :voteable_id]
    add_index :votings, [:voter_type, :voter_id]
    add_index :votings, [:voteable_type, :voteable_id, :voter_type, :voter_id], :name => "unique_voters", :unique => true
  end

  def self.down
    remove_index :votings, :column => [:voteable_type, :voteable_id]
    remove_index :votings, :column => [:voter_type, :voter_id]
    remove_index :votings, :name => "unique_voters"
    
    drop_table :votings
  end
end
