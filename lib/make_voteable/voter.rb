module MakeVoteable
  module Voter
    extend ActiveSupport::Concern

    included do
      has_many :votings, :class_name => "MakeVoteable::Voting", :as => :voter
    end

    module ClassMethods
      def voter?
        true
      end
    end

    # Up vote a +voteable+.
    # Raises an AlreadyVotedError if the voter already up voted the voteable.
    # Changes a down vote to an up vote if the the voter already down voted the voteable.
    def up_vote(voteable)
      check_voteable(voteable)

      voting = fetch_voting(voteable)

      if voting
        if voting.up_vote
          raise Exceptions::AlreadyVotedError.new(true)
        else
          voting.up_vote = true
          voteable.down_votes -= 1
          self.down_votes -= 1 if has_attribute?(:down_votes)
        end
      else
        voting = Voting.create(:voteable => voteable, :voter => self, :up_vote => true)
      end

      voteable.up_votes += 1
      self.up_votes += 1 if has_attribute?(:up_votes)

      Voting.transaction do
        save
        voteable.save
        voting.save
      end

      true
    end

    # Up votes the +voteable+, but doesn't raise an error if the votelable was already up voted.
    # The vote is simply ignored then.
    def up_vote!(voteable)
      begin
        up_vote(voteable)
        success = true
      rescue Exceptions::AlreadyVotedError
        success = false
      end
      success
    end

    # Down vote a +voteable+.
    # Raises an AlreadyVotedError if the voter already down voted the voteable.
    # Changes an up vote to a down vote if the the voter already up voted the voteable.
    def down_vote(voteable)
      check_voteable(voteable)

      voting = fetch_voting(voteable)

      if voting
        unless voting.up_vote
          raise Exceptions::AlreadyVotedError.new(false)
        else
          voting.up_vote = false
          voteable.up_votes -= 1
          self.up_votes -= 1 if has_attribute?(:up_votes)
        end
      else
        voting = Voting.create(:voteable => voteable, :voter => self, :up_vote => false)
      end

      voteable.down_votes += 1
      self.down_votes += 1 if has_attribute?(:down_votes)

      Voting.transaction do
        save
        voteable.save
        voting.save
      end

      true
    end

    # Down votes the +voteable+, but doesn't raise an error if the votelable was already down voted.
    # The vote is simply ignored then.
    def down_vote!(voteable)
      begin
        down_vote(voteable)
        success = true
      rescue Exceptions::AlreadyVotedError
        success = false
      end
      success
    end

    # Clears an already done vote on a +voteable+.
    # Raises a NotVotedError if the voter didn't voted for the voteable.
    def unvote(voteable)
      check_voteable(voteable)

      voting = fetch_voting(voteable)

      raise Exceptions::NotVotedError unless voting

      if voting.up_vote
        voteable.up_votes -= 1
        self.up_votes -= 1 if has_attribute?(:up_votes)
      else
        voteable.down_votes -= 1
        self.down_votes -= 1 if has_attribute?(:down_votes)
      end

      Voting.transaction do
        save
        voteable.save
        voting.destroy
      end

      true
    end

    # Clears an already done vote on a +voteable+, but doesn't raise an error if
    # the voteable was not voted. It ignores the unvote then.
    def unvote!(voteable)
      begin
        unvote(voteable)
        success = true
      rescue Exceptions::NotVotedError
        success = false
      end
      success
    end

    # Returns true if the voter voted for the +voteable+.
    def voted?(voteable)
      check_voteable(voteable)
      voting = fetch_voting(voteable)
      !voting.nil?
    end

    # Returns true if the voter up voted the +voteable+.
    def up_voted?(voteable)
      check_voteable(voteable)
      voting = fetch_voting(voteable)
      return false if voting.nil?
      return true if voting.has_attribute?(:up_vote) && voting.up_vote
      false
    end

    # Returns true if the voter down voted the +voteable+.
    def down_voted?(voteable)
      check_voteable(voteable)
      voting = fetch_voting(voteable)
      return false if voting.nil?
      return true if voting.has_attribute?(:up_vote) && !voting.up_vote
      false
    end

    private

    def fetch_voting(voteable)
      Voting.where(
        :voteable_type => voteable.class.to_s,
        :voteable_id => voteable.id,
        :voter_type => self.class.to_s,
        :voter_id => self.id).try(:first)
    end

    def check_voteable(voteable)
      raise Exceptions::InvalidVoteableError unless voteable.class.voteable?
    end
  end
end
