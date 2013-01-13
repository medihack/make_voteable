module MakeVoteable
  class Voting < ActiveRecord::Base
    attr_accessible :voteable, :voter, :voter_id, :voter_type, :up_vote

    belongs_to :voteable, :polymorphic => true
    belongs_to :voter, :polymorphic => true
  end
end
