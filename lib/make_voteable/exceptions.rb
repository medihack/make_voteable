module MakeVoteable
  module Exceptions
    class AlreadyVotedError < StandardError
      attr_reader :up_vote

      def initialize(up_vote)
        @up_vote = up_vote
      end
      
      def message
        if @up_vote
          vote = "up voted"
        else
          vote = "down voted"
        end

        "The voteable was already #{vote} by the voter."
      end
    end

    class NotVotedError < StandardError
      def message
        "The voteable was not voted by the voter."
      end
    end

    class InvalidVoteableError < StandardError
      def message
        "Invalid voteable."
      end
    end
  end
end
