// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Counter {
    struct Artist{
        uint256 id;
        string name;
        string artisteType;
        uint256 ticketsSold;
        address artistAddress;
    }
    struct Venue{
        uint256 id;
        string name;
        uint256 spaceAvailable;
        uint256 ticketPriceToTheVenue;
        address venueAddress;
    }
    struct Concert{
        uint256 id;
        uint256 artistId;
        uint256 venueId;
        uint256 date;
        bool isValidatedByArtist;
        bool isValidatedByVenue;
    }
    uint256 public nextconcertid = 1;
    uint256 public nextartistid = 1;
    uint256 public nextvenueid = 1;
    mapping (uint256 => Concert) public concerts;
    mapping (uint256 => Artist) public artists;
    mapping (uint256 => Venue) public venues;
    function CreateArtist(string memory _name, string memory _artisteType) public {
        require(artists[nextartistid].id == 0, "Artist already exists");
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(bytes(_artisteType).length > 0, "Artiste type cannot be empty");
        artists[nextartistid] = Artist(nextartistid, _name, _artisteType, 0, msg.sender);
        nextartistid++;
    }
    function ModifyArtist(uint256 _id, string memory _name, string memory _artisteType, uint256 _ticketsSold) public {
        require(artists[_id].id != 0, "Artist does not exist");
        require(artists[_id].artistAddress == msg.sender, "Only the artist can modify their details");
        artists[_id].name = _name;
        artists[_id].artisteType = _artisteType;
        artists[_id].ticketsSold = _ticketsSold;
    }
    function CreateVenue(string memory _name, uint256 _spaceAvailable, uint256 _ticketPriceToTheVenue) public {
        require(venues[nextvenueid].id == 0, "Venue already exists");
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(_spaceAvailable > 0, "Space available must be greater than zero");
        venues[nextvenueid] = Venue(nextvenueid, _name, _spaceAvailable, _ticketPriceToTheVenue, msg.sender);
        nextvenueid++;
    }
    function ModifyVenue(uint256 _id, string memory _name, uint256 _spaceAvailable, uint256 _ticketPriceToTheVenue) public {
        require(venues[_id].id != 0, "Venue does not exist");
        require(venues[_id].venueAddress == msg.sender, "Only the venue can modify their details");
        venues[_id].name = _name;
        venues[_id].spaceAvailable = _spaceAvailable;
        venues[_id].ticketPriceToTheVenue = _ticketPriceToTheVenue;
    }
    function CreateConcert(uint256 _artistId, uint256 _venueId, uint256 _date) public {
        require(concerts[nextconcertid].id == 0, "Concert already exists");
        require(artists[_artistId].id != 0, "Artist does not exist");
        require(venues[_venueId].id != 0, "Venue does not exist");
        concerts[nextconcertid] = Concert(nextconcertid, _artistId, _venueId, _date, false, false);
        nextconcertid++;
    }
    function ValidateConcertArtist(uint256 _concertId) public {
        require(concerts[_concertId].id != 0, "Concert does not exist");
        require(artists[concerts[_concertId].artistId].artistAddress == msg.sender, "Only the artist can validate this concert");
        concerts[_concertId].isValidatedByArtist = true;
    }
    function ValidateConcertVenue(uint256 _concertId) public {
        require(concerts[_concertId].id != 0, "Concert does not exist");
        require(venues[concerts[_concertId].venueId].venueAddress == msg.sender, "Only the venue can validate this concert");
        concerts[_concertId].isValidatedByVenue = true;
    }




}
