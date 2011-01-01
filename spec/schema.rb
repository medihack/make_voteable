ActiveRecord::Schema.define :version => 0 do
  create_table :voteable_models, :force => true do |t|
    t.string :name
    t.integer :up_votes, :null => false, :default => 0
    t.integer :down_votes, :null => false, :default => 0
  end

  create_table :voter_models, :force => true do |t|
    t.string :name
    t.integer :up_votes, :null => false, :default => 0
    t.integer :down_votes, :null => false, :default => 0
  end

  create_table :invalid_voteable_models, :force => true do |t|
    t.string :name
  end

  create_table :votings, :force => true do |t|
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
