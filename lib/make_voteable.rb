require 'make_voteable/voting'
require 'make_voteable/voteable'
require 'make_voteable/voter'
require 'make_voteable/exceptions'

module MakeVoteable
  def voteable?
    false
  end

  def voter?
    false
  end

  # Specify a model as voteable.
  #
  # Example:
  # class Question < ActiveRecord::Base
  #   make_voteable
  # end
  def make_voteable 
    include Voteable
  end

  # Specify a model as voter.
  #
  # Example:
  # class User < ActiveRecord::Base
  #   make_voter
  # end
  def make_voter
    include Voter
  end
end

ActiveRecord::Base.extend MakeVoteable
