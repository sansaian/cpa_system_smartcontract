pragma solidity ^0.4.0;
contract Registrator  {

    /*/
     *  Contract fields
    /*/
    address private owner;
    mapping (address => address) private dealStorage;
    mapping (address => uint) private storeUsers;
    address public cashierContract;

    /*/
     *  Events
    /*/
    event LogetDealAddress(address _advertiser, address _smartDeal);
    event LogstoreUser(address,uint);//role = 1 _advertiser role=2 webmaster
    event LogResultCreateSmartDeal(address _advertiser, address smart_smartDealDeal);
    event LogAddress(address);

    /*/
     *  Сonstructor
    /*/
    function Registrator(){
        owner = msg.sender;
        //create Casher
        cashierContract = new Casher(owner);
    }

    /*/
     *  Public functions
    /*/

    // @dev registers the user in the system
    // @returns role user
    // @param _user public key user
    // @param _role the role of the user in the system
    function registrationUser(address _user,uint _role) isOwner returns (uint) {
        storeUsers[_user] = _role;
        LogstoreUser(_user,  storeUsers[_user]);
        return storeUsers[_user];
    }


    // @dev Returns address DealsmartContract,which was created by the advertiser
    // if return value == 0x0 it means we have not inicialize deal
    // @param _advertiser the public key of the advertiser who has launched an advertising campaign
    function getAddress(address _advertiser) constant returns (address) {
        LogetDealAddress(_advertiser,  dealStorage[_advertiser]);
        return dealStorage[_advertiser];
    }

    // @dev creates a deal start advertising company
    // @returns address of smart contract SmartDeal
    // @param _advertiser - advertiser
    // @param costClick - the price for the attracted client
    function createSmartDeal(address _advertiser,uint costClick)isOwner returns (address) {
        if(cashierContract != 0x0){
            dealStorage[_advertiser] = new SmartDeal(cashierContract,_advertiser ,costClick);
      }
        LogResultCreateSmartDeal( _advertiser,dealStorage[_advertiser]);
        return dealStorage[_advertiser];
    }

    /*/
     *  Modifiers
    /*/
    modifier isOwner {
        if (msg.sender == owner)
        _;
    }

}




contract SmartDeal  {

    /*/
     *  Contract fields
    /*/
    address private owner;
    uint public costforclick;
    uint public countOfclick=0;
    address public advertiser;
    mapping (address => uint) private mappWebmastersClick;
    string advertiserReview;

    /*/
     *  Сonstructor
    /*/

    function SmartDeal(address _cashierContract, address _advertiser,uint _costClick){
        advertiser = _advertiser;
        owner = _cashierContract;
        costforclick = _costClick;
    }

    /*/
     *  Events
    /*/

    event LogIsWriteReview(address, bool);

    /*/
     *  Public functions
    /*/

    // @dev feedback from Advertiser
    // @param review
    function  writeAdvertiserReview (string _review) isAdvertiser {
        advertiserReview = _review;
        LogIsWriteReview(advertiser, true);
    }

    // @dev increase counter of attracted client
    // @returns count of attracted client
    // @param webmaster
    function increaseCountofClick(address webmaster) isOwner returns(uint){
        mappWebmastersClick[webmaster];
        countOfclick++;
        return countOfclick;
    }
     modifier isOwner {
        if (msg.sender == owner)
        _;
    }
     modifier isAdvertiser {
        if (msg.sender == advertiser)
        _;
    }

}

contract Casher {
    /*/
     *  Contract fields
    /*/
    address public owner;
    address public  registratorAddress;
    mapping (address => uint) private cashRegister;

    /*/
     *  Events
    /*/

    event LogClick(address _advertiser, bool result);
    event LogBalance(address ,uint);

    /*/
     *  Сonstructor
    /*/

    function Casher(address _owner){
        registratorAddress=msg.sender;
        owner = _owner;
    }

    /*/
     *  Public functions
    /*/

    // @dev charge tokens advertiser
    // @returns bool
    // @param _user - who to charge
    // @param _countToken how much to charge
    function chargeToken(address _user,uint _countToken) isOwner returns (bool){
        cashRegister[_user] +=_countToken;
        if(cashRegister[_user]==0)return false;
        return true;
    }

    // @dev the fact that attracted customer
    // @returns bool
    // @param _advertiser - advertiser
    // @param webMaster - webMaster
    // @param costOfClick from order
    function doClick(address _advertiser,address _webMaster,uint _costOfClick) isOwner
    returns(bool){
        if (cashRegister[_advertiser] < _costOfClick){
            LogClick(_advertiser,false);
            return false;
        }
        cashRegister[_advertiser]-=_costOfClick;
        cashRegister[_webMaster]+=_costOfClick;
        return increaseCountofClick(_advertiser,_webMaster);

    }

    // @dev increase number of referred customers in the contract SmartDeal
    // @returns bool
    // @param _advertiser - advertiser
    // @param webMaster - webMaster
    function  increaseCountofClick(address _advertiser,address _webMaster) private returns(bool){
        Registrator registrator = Registrator(registratorAddress);
        address contractSmartDeal =registrator.getAddress(_advertiser);
        LogBalance(contractSmartDeal ,1);
        if(contractSmartDeal!=0x0){
            SmartDeal smartDeal = SmartDeal(contractSmartDeal);
            uint countClick = smartDeal.increaseCountofClick(_webMaster);
            if(countClick>=0)
            return true;
        }
        return false;
    }
    // @dev check  user's balance
    // @returns the number of coins
    // @param _user
    function balanceOf(address _user) constant returns (uint256) {
        LogBalance(_user,cashRegister[_user]);
        return cashRegister[_user];
    }

    modifier isOwner {
        if (msg.sender == owner)
        _;
    }
}
