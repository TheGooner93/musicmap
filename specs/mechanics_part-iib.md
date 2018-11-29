# Game Mechanics Part IIb - Continuous Voting Model

## Vouch or Reject 

Instead of working with stage-oriented and politics-inspired challenging and voting mechanisms, we can also take a looser and more reputation-based approach, aligning better with a dynamic audience for which the challenging and voting mechanics might feel slow and cumbersome. In this approach, we propose a system of upvoting and downvoting, but where the registry tracks the entire history of votes (thus preferably on-chain, albeit with a compiled bulk of transactions). 

For each song, a user can vote (but only once) whether or not that song indeed belongs to the genre (vouch, check) or needs to be rejected (reject, cross). Therefore, voting reject equals challenging that song. Of course, a user can also take no action. When a user chooses either to vouch or reject, he or she will receive all the subsequent respective votes from the same direction as credit points. So if Alice chooses to reject, all the rejection votes from other users after hers will count towards her score. But also vice versa: if Bob chooses to vouch, he will receive all subsequent vouch votes. Each user will have a personal score (per genre), determined by:

User score = ⅀n(vouch) + ⅀n(reject)

There will therefore be three leaderboards or score rankings: the user with the highest vouch points or defender score, the user with the highest reject points or challenger score, and the user with the highest combination of both or arbiter score. These three leaderboard unlock different permissions.

The songs of a certain genre will be ranked according to the overall sum of votes by the simple formula:  

Song rating = ⅀(vouch) - ⅀(reject)

When a song has more reject votes than vouches, this will result in a negative score and these songs will be hidden from the main playlist (but can be made visible by the user). The total amount of song ratings (including the negative ones) will result in the overall genre score, which is a direct indicator of the genre’s popularity or activity.

Genre score = ⅀(song ratings)

Proposing a song will automatically add the song to the registry (there is no application stage) with a score of 0, and will also give you a user score of +1.


## Benefits & Drawbacks 

**Benefits ++++**

* The community has the ability to signal the most important, exemplary songs for that genre, making the playlist more interesting from an educational PoV (like original musicmap). The highest ranking songs should be the one most exemplary to that genre, i.e. the quintessential shortlist.
* There are less complex mechanics involved. There are only two actions per song.
* No more duration of voting and applying: faster filling of list.
* Workload (attention) is equally divided between all songs, users are more incentivized to cast votes for all songs instead of arbitrary ones.
* Your score can go up by doing nothing.
* The system does not rely on a minimum amount of curators for bootstrapping initial challenges and applications. Lists get filled and can be curated at any time without required response.
* Once a song is high in the list (lots of votes) it’s almost impossible to vote it out. This is a good thing, because it locks community-approved entries in place and prevents accidents of removing high-quality songs by glitches or unattendance of curators.


**Drawbacks ----**

* Due to the removal of an application stage, there is less control over which songs initially enter the registry.
> Add two registries: a good one (song rating of at least +3) and a bad or initial one (newly proposed songs (rating = 0) or rejected ones (negative score). Users will go hunt in the initial registry for good songs cause that can give them a high score.
* Less gamification (read: addiction) due to no possibility of special action achievements (no challenging, voting,...).
> Yes, but because these mechanics are gone, they also dont need to be incentivized
* The lists can contain songs that are very different from the Schelling point (genre)
> Solved with two registries.
* The risk vs reward function is weaker for signaling bad entries, i.e. applicants do not get slashed for proposing bad entries.
> When a song enters a damned state (rating -5 or less), the proposer gets punished by a score equal to the rating of the song (thus e.g. -5 to his user score) which will go on indefinitely (other way around?)
* More transactions to be stored?
* You cannot change your initial choice, which has eternal consequences
> Ability to withdraw your vote, but you lose all associated points and have to start from scratch again. 
* Malevolent actors can be not so easily punished: challenging (=rejecting) has no risk of losing stake.


## Attack Vectors & Problems


**Spam everything accept**  
You are more likely to win than to gain as the lists should be already 70-90% correct (estimate). This is also a quick way to bump artificially the overall score of a genre.
>    → Punishment for clicking accept when it gets rejected should be accordingly high.
    Punishment x 4 x avg user vote (=??)  
    → Optional: timelock and/or maximum amount of votes per user per day

**Troll Propose Attack**  
Spam propose as many songs as possible from a totally different genre.
 >   → Ban user from proposing within a genre after X amounts of damned songs  
    → Implement punishment for the proposer when a song gets removed.

**Waste by Negative Focus**  
If all songs are displayed with a score from +∞ until -∞, it is better to let users focus their efforts on positive votes (to have a good ranking). Time and effort placed in additional negative votes will exponentially decrease in value, because these songs do not belong on the list and consumers will also not listen to them. It is important for mass adoption to let the users do the least amount of work possible.
 >   → Implement a threshold in negative score after which a song gets removed from the entry.

**Diverging from Schelling Point**  
The initial bootstrapping phase is very important to set the right Schelling Point direction.
When the first 50-100 songs define a different schelling point than the actual genre definition, it is very hard to rectify, as the initial playlist - accepted by the community - will have become the source of truth.
>    → Define different, more strict rules for the first 50-100 songs  
    → Allow governance for the genre title and registry (to be changed, alterered or even subcategorized)  
    → WIKI should also mitigate this risk

**Personal User Troll Attacks**  
Certain users become targeted to decrease their user points and dethrone them from the leaderboard
>    → implement maximum anonimity, only show user names at leaderboard. Make sure user ID cannot be fetched from the back end

**Spam everything reject (with different accounts)**  
You will not lose any points but you will diminish the overall value of the genre. If you can do that with different accounts, you can hurt scores.
>    → make it so that user scores are not affected by the opposite votes (i.e. when i vote accept, the number of reject votes afterwards do not matter)  
    → track user IP? Make ID’s unique? Unique emailadresses?

**Coordinated group attack**  
Influence a large group of people by all voting in the same direction to win credit points or to bump or attack a specific song.
>    → Do not implement user fora or links to reddit channels to prevent coordinated attacks  
    → this attack is already mitigated because only the first ones will win a lot. The last in line never has any benefit for voting in the same direction that it was going.  
    → Implement time lock if a song receives more than X votes in Y time

**Skewing of Genres**  
>    → This is for later, but can be prevented by reward for bottom 20% of genres and penalty for top 20% of genres. This can be a fixed multiplier reward (x2, x1,5,...).

**Bootstrapping / Chicken or Egg problem**  
When the lists remain relatively empty, there will be no incentive to further fill them. Vicious cycle. An early mover advantage must be put into place.
>    → Ties in with different rules for initial registry. Reward first 50-100 songs harder.

**Bump to the top**  
Once a song has established lots of positive votes, it will become almost “untouchable”. Bumping a song fast to high place with different accounts can net the user lots of points and can also put incorrect songs for a long time in the list.
>    → Prevent many bumps within a limited timespan.

**Misinterpretation / Absence of Schelling Point**  
Consumers can assume the reject and vouch buttons are more like “likes” and “dislikes” where they just vote on music they like, and reject whatever they don’t like instead of objectively assessing whether or not it belongs to that genre.
>    → Make forking of genres easy and almost effortless so that toxic genres can become ignored and new schelling points established  
    → Add warning pop up with explanation before confirming all votes  
    → UI must use clear buttons with red cross for reject and green mark for vouch and certainly not thumbs up or down (like YouTube Music)

**Asymmetry of Voting Scale**  
Users will see the top first (with most positive votes) and therefore are more likely to already vote there. It would often be more lucrative to vote vouch than reject as this has the potential to earn a lot more votes, and also because the whitelist threshold has introduced an asymmetric voting scale.
>    → Add a multiplier reward for voting reject below 0.

**Plus versus Minus**  
It is not rewarding to vote reject for a song that has lots of positive votes ((or vice versa)), unless it will tip over to the other side of the scale, which is unlikely to happen. How to incentivize users to vote, even when it’s a high positive value?
>    → Rejection counter starts working immediately, not after it’s negative
    All the reject votes that come after your reject vote will count towards your score
    Therefore the higher the positive score, the more potential gain when rejecting

**King of Nothing**  
With a credit system per genre and permissions only granted for the top users within a genre, the community is being incentivized to make lots of genres and keep genre community small. Thus increasing their individual chances to unlock achievements. Making very small niche genres with a small community, quickly enables to be at the top, flooding the ecosystem with useless registries instead of establishing the perfect genre equilibrium.
>    → Set a minimum threshold in credit points before achievements get unlocked (e.g. 1000 points). This will make it almost impossible with niche lists to reap the rewards. Users are incentivized to make sure the registries will hold plenty of songs to gain lots of points but also with a good schelling point if they want to take full advantage of early mover advantage.
    Also registries that don’t have a total score of at least X, will not be pushed to the map.


## Governance Parameters


These are critical parameters that ought to be able to be changed by the top leaderboard or other curators. The finetuning of these parameters is essential to the survival of the ecosystem, but only known after many realtime simulations.

**PunishmentRejection**  
The punishment in negative credit points for the proposer when his proposal becomes removed from the registry  
**RemovalThreshold**  
The negative value of total votes from which a song permanently becomes removed from the registry (e.g. -10)  
**WhitelistThreshold**  
The positive value of votes from which a song becomes displayed in the main registry (.e.g. 3)  
**AchievementThreshold**  
The minimum credit score a user must have before being eligible to obtain achievements.  
**CartaThreshold**  
The minimum genre score a genre must have before it is displayed on the carta.

Eventually we want to have an ecosystem in place where the initial, immature registries (i.e. the first 50 or 100 entries) are more strictly curated for aforementioned reasons.
This can be done by implementing different parameters for this phase:
* Have at least 40% different artists (20 or 40).
* WhitelistThreshold increased to +5
* PunishmentRejection increased
* RemovalThreshold decreased to -5
* Max proposals per user?