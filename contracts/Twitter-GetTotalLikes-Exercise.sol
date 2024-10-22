// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Twitter {
    uint16 public MAX_TWEET_LENGTH = 280;

    struct Tweet {
        uint256 id;
        address author;
        string content;
        uint256 timestamp;
        uint256 likes;
    }
    
    // Mapping to store tweets by author
    mapping(address => Tweet[]) public tweets;
    address public owner;

    // Events
    event TweetCreated(
        uint256 id,
        address author,
        string content,
        uint256 timestamp
    );
    event TweetLiked(
        address liker,
        address tweetAuthor,
        uint256 tweetId,
        uint256 newLikeCount
    );
    event TweetUnliked(
        address unliker,
        address tweetAuthor,
        uint256 tweetId,
        uint256 newLikeCount
    );

    // Constructor to set the owner
    constructor() {
        owner = msg.sender;
    }

    // Modifier to restrict access to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "YOU ARE NOT THE OWNER!");
        _;
    }

    // Function to change the maximum allowed tweet length
    function changeTweetLength(uint16 newTweetLength) public onlyOwner {
        MAX_TWEET_LENGTH = newTweetLength;
    }

    // 1️⃣ Create a function to get total Tweet Likes for a given user
    function getTotalLikes(address _author) external view returns (uint256) {
        uint256 totalLikes = 0;

        // 2️⃣ Loop over all the tweets of the author
        for (uint256 i = 0; i < tweets[_author].length; i++) {
            // 3️⃣ Sum up the total likes
            totalLikes += tweets[_author][i].likes;
        }

        // 4️⃣ Return the total likes
        return totalLikes;
    }

    // Function to create a new tweet
    function createTweet(string memory _tweet) public {
        require(
            bytes(_tweet).length <= MAX_TWEET_LENGTH,
            "Tweet is too long!"
        );

        // Create a new tweet
        Tweet memory newTweet = Tweet({
            id: tweets[msg.sender].length,
            author: msg.sender,
            content: _tweet,
            timestamp: block.timestamp,
            likes: 0
        });

        // Store the new tweet
        tweets[msg.sender].push(newTweet);

        // Emit the TweetCreated event
        emit TweetCreated(
            newTweet.id,
            newTweet.author,
            newTweet.content,
            newTweet.timestamp
        );
    }

    // Function to like a tweet
    function likeTweet(address author, uint256 id) external {
        require(id < tweets[author].length, "TWEET DOES NOT EXIST");

        // Increment the like count
        tweets[author][id].likes++;

        // Emit the TweetLiked event
        emit TweetLiked(msg.sender, author, id, tweets[author][id].likes);
    }

    // Function to unlike a tweet
    function unlikeTweet(address author, uint256 id) external {
        require(id < tweets[author].length, "TWEET DOES NOT EXIST");
        require(tweets[author][id].likes > 0, "TWEET HAS NO LIKES");

        // Decrement the like count
        tweets[author][id].likes--;

        // Emit the TweetUnliked event
        emit TweetUnliked(msg.sender, author, id, tweets[author][id].likes);
    }

    // Function to retrieve a specific tweet of the caller
    function getTweet(uint256 _i) public view returns (Tweet memory) {
        return tweets[msg.sender][_i];
    }

    // Function to retrieve all tweets of a specific user
    function getAllTweets(address _owner) public view returns (Tweet[] memory) {
        return tweets[_owner];
    }
}
