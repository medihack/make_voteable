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
    class_eval do
      def self.voteable?
        true
      end

      include Voteable
    end
  end

  # Specify a model as voter.
  #
  # Example:
  # class User < ActiveRecord::Base
  #   make_voter
  # end
  def make_voter
    class_eval do
      def self.voter?
        true
      end

      include Voter
    end
  end
end

ActiveRecord::Base.extend MakeVoteable
