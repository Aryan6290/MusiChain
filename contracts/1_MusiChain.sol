pragma solidity ^0.4.2;

contract MusiChain{

   Music[] public songs;
   mapping(bytes32 => Music) songInfo;
   mapping(address => User) userInfo;

   event registerEvent(bytes32 songID);
   event licenseEvent(bytes32 songID, address authorized);
   event LogMusicID(bytes32 id);



   struct Music {
    bool registered;
    
    bytes32 ID;
    string name;
    string fileURL1;
    uint price;
    address owner;
    address[] licenseHoldersList;
    mapping(address => bool) licenseHolders;
  }


    struct User{
      bool registered;
      bytes32[] purchasedSongs;
      bytes32[] uploadedSongs;
    }

  function registerUser() public {
    userInfo[msg.sender].registered = true;

  }


  function buyLicense(bytes32 songID) public payable {
    uint price = songInfo[songID].price;
    require(msg.value >= price,"Amount sent is less than required amount for the song");
    userInfo[msg.sender].purchasedSongs.push(songID);

    songInfo[songID].licenseHolders[msg.sender] = true;
    songInfo[songID].licenseHoldersList.push(msg.sender);
    // pay the coopyright holder
    payRoyalty(songID, msg.value);

    emit licenseEvent(songID, msg.sender);
  }


  function payRoyalty(bytes32 songID, uint amount) private {
    address owner = songInfo[songID].owner;
    owner.transfer(amount);
  }


  function addMusic(string name, string URL1,uint price) public {


    bytes32 songID = keccak256(name, URL1, songs.length);
    songInfo[songID].registered = true;
    songInfo[songID].ID = songID;
    songInfo[songID].name = name;
    songInfo[songID].price = price;
    songInfo[songID].fileURL1 = URL1;

    emit registerEvent(songID);
    songs.push(songInfo[songID]);
  }

  function getSongList() public view returns (bytes32[]) {
    bytes32[] memory response = new bytes32[](songs.length);
    for (uint i = 0; i < songs.length; i++) {
      Music storage song = songs[i];
      response[i]= song.ID;
    }

    return response;
  }

  function getPurchasedList() public view returns (bytes32[]){
    return userInfo[msg.sender].purchasedSongs;
  }
}
