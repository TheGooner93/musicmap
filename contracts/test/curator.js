var Curator = artifacts.require("Curator");

contract("Curator", function(accounts){
    describe("Curator Interaction", function(){
        it("Should succesfully perform a VOUCH vote", function(){
            return Curator.deployed().then(function(instance){
                return instance.vouchOrReject.call("t1", true, {from: accounts[0]});
            }).then(function(voteSuccessful){
                assert.equal(voteSuccessful, true, "Voting is successful");
            });
        });
    
        it("Should succesfully perform a REJECT vote", function(){
            return Curator.deployed().then(function(instance){
                return instance.vouchOrReject.call("t1", false, {from: accounts[1]});
            }).then(function(voteSuccessful){
                assert.equal(voteSuccessful, true, "Voting is successful");
            });
        });
    
        it("Should reset all available user votes", function(){
            return Curator.deployed().then(function(instance){
                return instance.resetVoteCount.call();
            }).then(function(isDone){
                assert.equal(isDone, true,"Votes reset!");
            });
        });
    })
})