require File.expand_path('../../spec_helper', __FILE__)

describe "Make Voteable" do
  before(:each) do
    @voteable = VoteableModel.create(:name => "Votable 1")
    @voter = VoterModel.create(:name => "Voter 1")
  end

  it "should create a voteable instance" do
    @voteable.class.should == VoteableModel
    @voteable.class.voteable?.should == true
  end

  it "should create a voter instance" do
    @voter.class.should == VoterModel
    @voter.class.voter?.should == true
  end

  it "should get correct vote summary" do
    @voter.up_vote(@voteable).should == true
    @voteable.votes.should == 1
    @voter.down_vote(@voteable).should == true
    @voteable.votes.should == -1
    @voter.unvote(@voteable).should == true
    @voteable.votes.should == 0
  end

  it "voteable should have up vote votings" do
    @voteable.votings.length.should == 0
    @voter.up_vote(@voteable)
    @voteable.votings.reload.length.should == 1
    @voteable.votings[0].up_vote?.should be_true
  end

  it "voter should have up vote votings" do
    @voter.votings.length.should == 0
    @voter.up_vote(@voteable)
    @voter.votings.reload.length.should == 1
    @voter.votings[0].up_vote?.should be_true
  end

  it "voteable should have down vote votings" do
    @voteable.votings.length.should == 0
    @voter.down_vote(@voteable)
    @voteable.votings.reload.length.should == 1
    @voteable.votings[0].up_vote?.should be_false
  end

  it "voter should have down vote votings" do
    @voter.votings.length.should == 0
    @voter.down_vote(@voteable)
    @voter.votings.reload.length.should == 1
    @voter.votings[0].up_vote?.should be_false
  end

  describe "up vote" do
    it "should increase up votes of voteable by one" do
      @voteable.up_votes.should == 0
      @voter.up_vote(@voteable)
      @voteable.up_votes.should == 1
    end

    it "should increase up votes of voter by one" do
      @voter.up_votes.should == 0
      @voter.up_vote(@voteable)
      @voter.up_votes.should == 1
    end

    it "should create a voting" do
      MakeVoteable::Voting.count.should == 0
      @voter.up_vote(@voteable)
      MakeVoteable::Voting.count.should == 1
      voting = MakeVoteable::Voting.first
      voting.voteable.should == @voteable
      voting.voter.should == @voter
      voting.up_vote.should == true
    end

    it "should only allow a voter to up vote a voteable once" do
      @voter.up_vote(@voteable)
      lambda { @voter.up_vote(@voteable) }.should raise_error(MakeVoteable::Exceptions::AlreadyVotedError)
    end

    it "should only allow a voter to up vote a voteable once without raising an error" do
      @voter.up_vote!(@voteable)
      lambda {
        @voter.up_vote!(@voteable).should == false
      }.should_not raise_error(MakeVoteable::Exceptions::AlreadyVotedError)
      MakeVoteable::Voting.count.should == 1
    end

    it "should change a down vote to an up vote" do
      @voter.down_vote(@voteable)
      @voteable.up_votes.should == 0
      @voteable.down_votes.should == 1
      @voter.up_votes.should == 0
      @voter.down_votes.should == 1
      MakeVoteable::Voting.count.should == 1
      MakeVoteable::Voting.first.up_vote.should be_false
      @voter.up_vote(@voteable)
      @voteable.up_votes.should == 1
      @voteable.down_votes.should == 0
      @voter.up_votes.should == 1
      @voter.down_votes.should == 0
      MakeVoteable::Voting.count.should == 1
      MakeVoteable::Voting.first.up_vote.should be_true
    end

    it "should allow up votes from different voters" do
      @voter2 = VoterModel.create(:name => "Voter 2")
      @voter.up_vote(@voteable)
      @voter2.up_vote(@voteable)
      @voteable.up_votes.should == 2
      MakeVoteable::Voting.count.should == 2
    end

    it "should raise an error for an invalid voteable" do
      invalid_voteable = InvalidVoteableModel.create
      lambda { @voter.up_vote(invalid_voteable) }.should raise_error(MakeVoteable::Exceptions::InvalidVoteableError)
    end

    it "should check if voter up voted voteable" do
      @voter.up_vote(@voteable)
      @voter.voted?(@voteable).should be_true
      @voter.up_voted?(@voteable).should be_true
      @voter.down_voted?(@voteable).should be_false
    end
  end

  describe "vote down" do
    it "should decrease down votes of voteable by one" do
      @voteable.down_votes.should == 0
      @voter.down_vote(@voteable)
      @voteable.down_votes.should == 1
    end

    it "should decrease down votes of voter by one" do
      @voter.down_votes.should == 0
      @voter.down_vote(@voteable)
      @voter.down_votes.should == 1
    end

    it "should create a voting" do
      MakeVoteable::Voting.count.should == 0
      @voter.down_vote(@voteable)
      MakeVoteable::Voting.count.should == 1
      voting = MakeVoteable::Voting.first
      voting.voteable.should == @voteable
      voting.voter.should == @voter
      voting.up_vote.should == false
    end

    it "should only allow a voter to down vote a voteable once" do
      @voter.down_vote(@voteable)
      lambda { @voter.down_vote(@voteable) }.should raise_error(MakeVoteable::Exceptions::AlreadyVotedError)
    end

    it "should only allow a voter to down vote a voteable once without raising an error" do
      @voter.down_vote!(@voteable)
      lambda {
        @voter.down_vote!(@voteable).should == false
      }.should_not raise_error(MakeVoteable::Exceptions::AlreadyVotedError)
      MakeVoteable::Voting.count.should == 1
    end

    it "should change an up vote to a down vote" do
      @voter.up_vote(@voteable)
      @voteable.up_votes.should == 1
      @voteable.down_votes.should == 0
      @voter.up_votes.should == 1
      @voter.down_votes.should == 0
      MakeVoteable::Voting.count.should == 1
      MakeVoteable::Voting.first.up_vote.should be_true
      @voter.down_vote(@voteable)
      @voteable.up_votes.should == 0
      @voteable.down_votes.should == 1
      @voter.up_votes.should == 0
      @voter.down_votes.should == 1
      MakeVoteable::Voting.count.should == 1
      MakeVoteable::Voting.first.up_vote.should be_false
    end

    it "should allow down votes from different voters" do
      @voter2 = VoterModel.create(:name => "Voter 2")
      @voter.down_vote(@voteable)
      @voter2.down_vote(@voteable)
      @voteable.down_votes.should == 2
      MakeVoteable::Voting.count.should == 2
    end

    it "should raise an error for an invalid voteable" do
      invalid_voteable = InvalidVoteableModel.create
      lambda { @voter.down_vote(invalid_voteable) }.should raise_error(MakeVoteable::Exceptions::InvalidVoteableError)
    end

    it "should check if voter down voted voteable" do
      @voter.down_vote(@voteable)
      @voter.voted?(@voteable).should be_true
      @voter.up_voted?(@voteable).should be_false
      @voter.down_voted?(@voteable).should be_true
    end
  end

  describe "unvote" do
    it "should decrease the up votes if up voted before" do
      @voter.up_vote(@voteable)
      @voteable.up_votes.should == 1
      @voter.up_votes.should == 1
      @voter.unvote(@voteable)
      @voteable.up_votes.should == 0
      @voter.up_votes.should == 0
    end

    it "should remove the voting" do
      @voter.up_vote(@voteable)
      MakeVoteable::Voting.count.should == 1
      @voter.unvote(@voteable)
      MakeVoteable::Voting.count.should == 0
    end

    it "should raise an error if voter didn't vote for the voteable" do
      lambda { @voter.unvote(@voteable) }.should raise_error(MakeVoteable::Exceptions::NotVotedError)
    end

    it "should not raise error if voter didn't vote for the voteable and unvote! is called" do
      lambda {
        @voter.unvote!(@voteable).should == false
      }.should_not raise_error(MakeVoteable::Exceptions::NotVotedError)
    end

    it "should raise an error for an invalid voteable" do
      invalid_voteable = InvalidVoteableModel.create
      lambda { @voter.unvote(invalid_voteable) }.should raise_error(MakeVoteable::Exceptions::InvalidVoteableError)
    end
  end
end
