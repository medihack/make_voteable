class VoteableModel < ActiveRecord::Base
  make_voteable
end

class VoterModel < ActiveRecord::Base
  make_voter
end

class InvalidVoteableModel < ActiveRecord::Base
end

class User < ActiveRecord::Base
  make_voter
end

class Admin < User
end
