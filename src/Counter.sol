// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract Counter {
    event ConcertCreated(uint256 concertId, uint256 artistId, uint256 venueId, uint256 date);
    event TicketPurchased(uint256 ticketId, uint256 concertId, address buyer);
    event ConcertValidatedByArtist(uint256 concertId);
    event TicketTransferred(uint256 ticketId, address to, uint256 ticketPrice);
    event ConcertValidatedByVenue(uint256 concertId);
    event ArtistCreated(uint256 artistId, string name, string artisteType);
    event TicketCreated(uint256 ticketId, uint256 concertId, address owner);
    event VenueCreated(uint256 venueId, string name, uint256 spaceAvailable, uint256 ticketPourcentToTheVenue);
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
        uint256 ticketPourcentToTheVenue;
        address venueAddress;
    }
    struct Concert{
        uint256 id;
        uint256 artistId;
        uint256 venueId;
        uint256 date;
        bool isValidatedByArtist;
        bool isValidatedByVenue;
        uint256 attendance;
        uint256 revenueArtist;
        uint256 revenueVenue;
    }
    struct Ticket{
        uint256 id;
        uint256 concertId;
        uint256 ticketPrice;
        address owner;
    }
    uint256 public nextconcertid = 1;
    uint256 public nextartistid = 1;
    uint256 public nextvenueid = 1;
    uint256 public nextticketid = 1;
    mapping (uint256 => Ticket) public tickets;
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
    function ModifyArtist(uint256 _id, string memory _name, string memory _artisteType) public {
        require(artists[_id].id != 0, "Artist does not exist");
        require(artists[_id].artistAddress == msg.sender, "Only the artist can modify their details");
        artists[_id].name = _name;
        artists[_id].artisteType = _artisteType;
    }
    function CreateVenue(string memory _name, uint256 _spaceAvailable, uint256 _ticketPourcentToTheVenue) public {
        require(venues[nextvenueid].id == 0, "Venue already exists");
        require(bytes(_name).length > 0, "Name cannot be empty");
        require(_spaceAvailable > 0, "Space available must be greater than zero");
        venues[nextvenueid] = Venue(nextvenueid, _name, _spaceAvailable, _ticketPourcentToTheVenue,msg.sender);
        nextvenueid++;
        emit VenueCreated(nextvenueid - 1, _name, _spaceAvailable, _ticketPourcentToTheVenue);
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
        concerts[nextconcertid] = Concert(nextconcertid, _artistId, _venueId, _date, false, false, 0, 0, 0);
        nextconcertid++;
        emit ConcertCreated(nextconcertid - 1, _artistId, _venueId, _date);
    }
    function ValidateConcertArtist(uint256 _concertId) public {
        require(concerts[_concertId].id != 0, "Concert does not exist");
        require(artists[concerts[_concertId].artistId].artistAddress == msg.sender, "Only the artist can validate this concert");
        concerts[_concertId].isValidatedByArtist = true;
        emit ConcertValidatedByArtist(_concertId);
    }
    function ValidateConcertVenue(uint256 _concertId) public {
        require(concerts[_concertId].id != 0, "Concert does not exist");
        require(venues[concerts[_concertId].venueId].venueAddress == msg.sender, "Only the venue can validate this concert");
        concerts[_concertId].isValidatedByVenue = true;
        emit ConcertValidatedByVenue(_concertId);
    }
    function CreateTicket(uint256 _concertId,uint256 _ticketPrice) public {
        require(concerts[_concertId].id != 0, "Concert does not exist");
        require(concerts[_concertId].isValidatedByArtist, "Concert is not validated by artist");
        require(concerts[_concertId].isValidatedByVenue, "Concert is not validated by venue");
        uint256 venueId = concerts[_concertId].venueId;
        require(venues[venueId].spaceAvailable > 0, "No space available in the venue");
        tickets[nextticketid] = Ticket(nextticketid, _concertId, _ticketPrice, msg.sender);
        venues[venueId].spaceAvailable--;
        
        uint256 artistId = concerts[_concertId].artistId;
        artists[artistId].ticketsSold++;
        nextticketid++;
        emit TicketCreated(nextticketid - 1, _concertId, msg.sender);
    }
    function UseTicket(uint256 _ticketId, uint256 _concertId) public {
        require(tickets[_ticketId].id != 0, "Ticket does not exist");
        require(tickets[_ticketId].owner == msg.sender, "Only the owner can use this ticket");
        require(tickets[_ticketId].concertId == _concertId, "Ticket is not valid for this concert");
        require(block.timestamp - concerts[_concertId].date <= 86400, "Registration has not started yet");
        require(block.timestamp - concerts[_concertId].date < 0, "Concert has already ended");
        concerts[_concertId].attendance++;
        delete tickets[_ticketId];
    }
    function BuyTicket(uint256 _ticketId) public payable{
        require(tickets[_ticketId].id != 0, "Ticket does not exist");
        require(tickets[_ticketId].owner != msg.sender, "Owner cannot buy their own ticket");
        require(msg.value >= tickets[_ticketId].ticketPrice, "Insufficient funds to buy the ticket");
        address previousOwner = tickets[_ticketId].owner;
        uint256 venueId = concerts[tickets[_ticketId].concertId].venueId;
        tickets[_ticketId].owner = msg.sender;
        payable(address(this)).transfer(msg.value);
        concerts[tickets[_ticketId].concertId].revenueVenue += (tickets[_ticketId].ticketPrice * venues[venueId].ticketPourcentToTheVenue) / 100;
        concerts[tickets[_ticketId].concertId].revenueArtist += (tickets[_ticketId].ticketPrice * (100 - venues[venueId].ticketPourcentToTheVenue)) / 100;
        emit TicketPurchased(_ticketId, tickets[_ticketId].concertId, msg.sender);
    }
    function TransferTicket(uint256 _ticketId, address _to, uint256 _ticketPrice) public payable {
        require(tickets[_ticketId].id != 0, "Ticket does not exist");
        require(tickets[_ticketId].owner == msg.sender, "Only the owner can transfer this ticket");
        require(_to != address(0), "Transfer the ticket to a valid address");
        require(msg.value <= tickets[_ticketId].ticketPrice, "Cant sell the ticket for more than its original price");
        require(msg.value == _ticketPrice, "Insufficient funds to transfer the ticket");
        tickets[_ticketId].owner = _to;
        payable(msg.sender).transfer(msg.value);
        emit TicketTransferred(_ticketId, _to, _ticketPrice);
    }
    function CashOutArtist(uint256 _artistId,uint256 _concertId) public {
        require(artists[_artistId].id != 0, "Artist does not exist");
        require(artists[_artistId].artistAddress == msg.sender, "Only the artist can cash out their revenue");
        uint256 amount_artist = concerts[_concertId].revenueArtist;
        uint256 amount_venue = concerts[_concertId].revenueVenue;
        require(amount_artist > 0, "No revenue to cash out for artist");
        require(amount_venue > 0, "No revenue to cash out for venue");
        require(block.timestamp > concerts[_concertId].date + 1 days, "Concert has not ended yet");
        concerts[_concertId].revenueArtist = 0;
        concerts[_concertId].revenueVenue = 0;
        payable(msg.sender).transfer(amount_artist);
        address venueAddress = venues[concerts[_concertId].venueId].venueAddress;
        payable(venueAddress).transfer(amount_venue);
    }
   




}
