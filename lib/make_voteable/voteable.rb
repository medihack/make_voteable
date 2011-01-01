module MakeVoteable
  module Voteable

    # Return the difference of down and up votes.
    # May be negative if there are more down than up votes.
    def votes
      self.up_votes - self.down_votes
    end
  end
end
