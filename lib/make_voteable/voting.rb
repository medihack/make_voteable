module MakeVoteable
  class Voting < ActiveRecord::Base
    belongs_to :voteable, :polymorphic => true
    belongs_to :voter, :polymorphic => true
  end
end
