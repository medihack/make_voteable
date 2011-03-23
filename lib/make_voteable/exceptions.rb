module MakeVoteable
  module Exceptions
    class AlreadyVotedError < StandardError
      attr_reader :up_vote

      def initialize(up_vote)
        vote = if up_vote
          "up voted"
        else
          "down voted"
        end

        super "The voteable was already #{vote} by the voter."
      end
    end

    class NotVotedError < StandardError
      def initialize
        super "The voteable was not voted by the voter."
      end
    end

    class InvalidVoteableError < StandardError
      def initialize
        super "Invalid voteable."
      end
    end
  end
end
