pragma solidity ^0.5.0;

/// @title A smart contract for music curation
/// @author TheGooner93
/// @notice Enables voting mechanisms for users in a single music genre
contract Curator {
    /**************  variables **********************/
    int public genreScore ;
    uint public totalTracks ;
    int public averageScore;                        
    
    //mapping of a userid to a users struct
    mapping(address => Users) public musicMapUsers;
    //mapping for trackhash to song details
    mapping(bytes32 => Track) public musicMapTracks;
    
    address[] public allUsers;
    bytes32[] public allTracks;
    /************* structs ***************/
    struct Track {
        bytes32 hash;                            //this is a hash of all metadata(trackId) 
        int score;                               //sum total of positive and negative votes for this track
        mapping(address => Vote) userVotes;      //total users who voted for this track and mapping of userId with Votes struct
        State state;                             //state of the track
    }
    struct Users {
        address id;                              //public key of a user
        int vouchCredits;                        //total credits earned by user when vouched for a track
        int rejectCredits;                       //total credits earned by user when rejected a track
        mapping (bytes32 => Vote) votes;         //tracks all songs this user has voted on and mapping of track hash with user’s vote
        mapping (bytes32 => bool) penaltyTracks; //tracks the songs for which the user has paid a penalty due to opposite threshold violation
        uint dayVoteCount;
    }
    
    /**************  constants ********************/
    uint8 constant WhitelistThreshold = 10;
    int16 constant BlacklistThreshold = -100;
    uint8 constant UserDailyVoteCap = 10;
    uint8 constant PunishmentMultiplier = 5;
    
    /**************** enums *****************/
    enum Vote {NOVOTE, VOUCH, REJECT}
    enum State {NONEXISTENT, BLACKLIST, SANDBOX, WHITELIST}
    
    /****** functions *********/
    
    /// @author TheGooner93
    /// @notice Vouch or reject the given track based on user vote 
    /// @param trackHashString Hash of the track being voted upon
    /// @param didVouch Indicates whether tracks was vouched or rejected
    function vouchOrReject (string memory trackHashString, bool didVouch) public{
        bytes32 trackHash;
        assembly{
             trackHash := mload(add(trackHashString,32))
        }
        
        address userId = msg.sender;
        
        //check if user has not already voted for this track
        bool hasVoted = hasUserVotedForTrack(trackHash, userId);
        
        //if the user has not voted already on this track, and their daily vote cap has not yet been reached
        if(!hasVoted && !_isVoteCapReached(userId)){
           //update above mappings appropritely after calculating new state of the track in playlist 
           //and appropriate credits for this user and other users who voted for this track
            if(_isRejected(trackHash) == false){
                _distributeCredits(trackHash, didVouch, userId);
                _updateAverageScore();
            }
            
        }
    }
    
    /// @author TheGooner93
    /// @notice Distributes credits appropriately based on game mechanics 
    /// @param trackHash Hash of the track being voted upon
    /// @param didVouch Indicates whether tracks was vouched or rejected
    /// @param userId Address of the user
    function _distributeCredits(bytes32 trackHash, bool didVouch, address userId) private {
            
        //Apply votes
        if(didVouch){
            //Distribute credits to previous vouch-ers
            for(uint i = 0; i<allUsers.length; i++){
                if(musicMapTracks[trackHash].userVotes[allUsers[i]] == Vote.VOUCH){
                    musicMapUsers[allUsers[i]].vouchCredits += 1;
                }
            }
            
            //Apply the type of vote against the track for a particular user, and for a user against a particular track
            musicMapUsers[userId].votes[trackHash] = Vote.VOUCH;
            musicMapTracks[trackHash].userVotes[userId] = Vote.VOUCH;
            
            //Incrementing the score only in case of an existing track
            if(_hashCompare(musicMapTracks[trackHash].hash, trackHash) != false){
                musicMapTracks[trackHash].score += 1;
            }
            //Update the genreScore
            genreScore += 1;
            
        }else{
            //Distribute credits to previous rejecters
            for(uint i = 0; i<allUsers.length; i++){
                if(musicMapTracks[trackHash].userVotes[allUsers[i]] == Vote.REJECT){
                    musicMapUsers[allUsers[i]].rejectCredits += 1;
                }
            }
            
            //Apply the type of vote against the track for a particular user, and for a user against a particular track
            musicMapUsers[userId].votes[trackHash] = Vote.REJECT;
            musicMapTracks[trackHash].userVotes[userId] = Vote.REJECT;
            
            //Decrementing the score only in case of an existing track
            if(_hashCompare(musicMapTracks[trackHash].hash, trackHash) != false){
                musicMapTracks[trackHash].score -= 1;
            }
            
            //Update the genreScore
            genreScore -= 1;
        }
        
        //Entering the trackHash, only if it isnt already existent
        if(_hashCompare(musicMapTracks[trackHash].hash, trackHash) == false){
            musicMapTracks[trackHash].hash = trackHash;
            allTracks.push(trackHash);
            totalTracks += 1;
             //Entering any new track into SANDBOX registry and it gets initialized with a score of zero
            musicMapTracks[trackHash].state = State.SANDBOX;
        }
        
        //Entering the user, only if their details is not already existent
        if(musicMapUsers[userId].id != userId){
            musicMapUsers[userId].id = userId;
            allUsers.push(userId);
        }
        
        //Update the day vote count for the user
        musicMapUsers[userId].dayVoteCount += 1;
        
        //Update State of track in case of threshold breach
        if(musicMapTracks[trackHash].score > int(WhitelistThreshold)){
            musicMapTracks[trackHash].state = State.WHITELIST;
            _applyRelevantPenalties(trackHash);
        }else if(musicMapTracks[trackHash].score < BlacklistThreshold){
            musicMapTracks[trackHash].state = State.BLACKLIST;
            _applyRelevantPenalties(trackHash);
        }else{
            musicMapTracks[trackHash].state = State.SANDBOX;
        }
    }
    
    /// @author TheGooner93
    /// @notice Updates average score of this genre with every user action
    function _updateAverageScore() private{
        averageScore = genreScore/int256(totalTracks);
    }
    
    /// @author TheGooner93
    /// @notice Checks if given track is rejected ie. is in the blacklist
    /// @param trackHash Hash of the track being voted upon
    /// @return true if the track has been blacklisted
    function _isRejected(bytes32 trackHash) public view returns(bool){
        if(musicMapTracks[trackHash].state == State.BLACKLIST){
            return true;
        }
        return false;
    }
    
    //New functions
    
    /// @author TheGooner93
    /// @notice Checks if user has voted for a particular track
    /// @param trackHash Hash of the track being voted upon
    /// @param userId Address of the user
    /// @return true if the user has already voted for a track
    function hasUserVotedForTrack(bytes32 trackHash, address userId) private view returns(bool){
      Users storage matchedUser = musicMapUsers[userId];
      Vote matchedUserVote = matchedUser.votes[trackHash];
      if(matchedUserVote == Vote.VOUCH || matchedUserVote == Vote.REJECT){
          return true;
       }else{
          return false;
       }  
    }
    
    /// @author TheGooner93
    /// @notice Hash comparison function
    /// @param string1 First track hash
    /// @param string2 Second track hash
    /// @return true if string1 and string2 are the same, returns false if not
    function _hashCompare(bytes32 string1, bytes32 string2) private pure returns(bool){
        if(keccak256(abi.encode(string1)) == keccak256(abi.encode(string2))){
            return true;
        }else{
            return false;
        }
    }
    
    /// @author TheGooner93
    /// @notice Checks if the maximum vote cap for the day is reached
    /// @param userId Address of the user
    /// @return true if the maximum vote cap for the day for the userId is reached
    function _isVoteCapReached(address userId) private view returns(bool){
        if(musicMapUsers[userId].dayVoteCount == UserDailyVoteCap){
            return true;
        }else{
            return false;
        }
    }
    
    /// @author TheGooner93
    /// @notice Resets all vote counts
    function resetVoteCount() public{
        for(uint i = 0; i<allUsers.length; i++){
            if(musicMapUsers[allUsers[i]].dayVoteCount != 0){
                musicMapUsers[allUsers[i]].dayVoteCount = 0;
            }
        }
    }
    
    /// @author TheGooner93
    /// @notice Applies penalties for users with conflicting votes
    /// @param trackHash Hash of the track pertaining to penalty applied
    function _applyRelevantPenalties(bytes32 trackHash) private{
        if(musicMapTracks[trackHash].state == State.WHITELIST){
            for(uint i = 0; i<allUsers.length;i++){
                //if user has voted 'Reject' on this track and if no penalty has been awarded yet for this track
                if(musicMapTracks[trackHash].userVotes[allUsers[i]] == Vote.REJECT && musicMapUsers[allUsers[i]].penaltyTracks[trackHash] != true){
                    //Slash challenger score by (TR-WT)
                    musicMapUsers[allUsers[i]].rejectCredits = musicMapUsers[allUsers[i]].rejectCredits - (musicMapTracks[trackHash].score - int(WhitelistThreshold));
                    //Add to penaltyTracks
                    musicMapUsers[allUsers[i]].penaltyTracks[trackHash] = true;
                }
            }
        }else if(musicMapTracks[trackHash].state == State.BLACKLIST){
            for(uint i = 0; i<allUsers.length;i++){
                //if user has voted 'Vouch' on this track and if no penalty has been awarded yet for this track
                if(musicMapTracks[trackHash].userVotes[allUsers[i]] == Vote.VOUCH && musicMapUsers[allUsers[i]].penaltyTracks[trackHash] != true){
                    //Slash defender score by PunishmentMultiplier * averageScore
                    int256 slashAmount = int256(PunishmentMultiplier) * averageScore;
                    if(slashAmount >= 0){
                       musicMapUsers[allUsers[i]].vouchCredits = musicMapUsers[allUsers[i]].vouchCredits - slashAmount;
                    }else{
                       musicMapUsers[allUsers[i]].vouchCredits = musicMapUsers[allUsers[i]].vouchCredits + slashAmount;
                    }
                    //Add to penaltyTracks
                    musicMapUsers[allUsers[i]].penaltyTracks[trackHash] = true;
                }
            }
        }
    }
}