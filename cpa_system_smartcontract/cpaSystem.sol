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
    event LogstoreUser(address,uint);//role = 1 _advertiser role=2
    event LogResultCreateSmartDeal(address _advertiser, address smart_smartDealDeal);
    event LogAddress(address);

    /*/
     *  Сonstructor
    /*/
    function Registrator(){
        owner = msg.sender;
        cashierContract = new Casher(owner);
        //создадим кэшэра
        //todo dealStorage[_sender] = new SmartDeal(_docHash,_url, _sender, _recipient);

    }

    /*/
     *  Public functions
    /*/
    //todo можно добавить enum
    function registrationUser(address _user,uint _role) isOwner returns (uint) {
       storeUsers[_user] = _role;
       LogstoreUser(_user,  storeUsers[_user]);
        return storeUsers[_user];
    }


    // @dev Returns address DealsmartContract,which was created by the advertiser
    //if return value == 0x0 it means we have not inicialize deal
    // @param address smart contract where _advertiser is advertiser
    function getAddress(address _advertiser) constant returns (address) {
       LogetDealAddress(_advertiser,  dealStorage[_advertiser]);
        return dealStorage[_advertiser];
    }

    // @dev Returns address cmartContract
    // @param
    // @param
    // @param
    function createSmartDeal(address _advertiser,uint costClick) returns (address) {
         if(cashierContract != 0x0){
            //  if(storeUsers[msg.sender]!= 0)
                dealStorage[_advertiser] = new SmartDeal(owner,_advertiser ,costClick);

       //to do логер
      // check create contract
      }
        LogResultCreateSmartDeal( _advertiser,dealStorage[_advertiser]);
        return dealStorage[_advertiser];
    }

    // @dev create SmartContract SertificationCentr and return its address
    // function createSertificationCentr() isOwner returns(address){
    //     cashierContract = new SertificationCentr(owner);
    //     LogAddress(sertCentrAdress);
    //     return sertCentrAdress;
    // }

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

        // status=0 - create contract
        // status=1 - contract activate the contract has at least one webmaster
     uint public countOfclick=0;
     address public advertiser;
    mapping (address => uint) private mappWebmastersClick;
    string advertiserReview;

    /*/
     *  Сonstructor
    /*/
    function SmartDeal(address _owner, address _advertiser,uint _costClick){
        advertiser = _advertiser;
        owner = _owner;
        costforclick = _costClick;
        //создадим кэшэра
        //todo dealStorage[_sender] = new SmartDeal(_docHash,_url, _sender, _recipient);
    }

    /*/
     *  Public functions
    /*/
    function  writeAdvertiserReview (string _review) {
        //todo сделать модификаторы
        advertiserReview = _review;
    }

    function  writeWebMasterReview (string _review) {
        //todo сделать модификаторы
        advertiserReview = _review;
    }

    function increaseCountofClick(address webmaster) returns(uint){
        mappWebmastersClick[webmaster];
        countOfclick++;
        return countOfclick;
    }
     modifier isOwner {
        if (msg.sender == owner)
        _;
    }
}

contract Casher {

    address public owner;
    address public  registratorAddress;
    mapping (address => uint) private cashRegister;
    event LogClick(address _advertiser, bool result);
    event LogBalance(address ,uint);

    function Casher(address _owner){
        registratorAddress=msg.sender;
        owner = _owner;
    }

    function chargeToken(address _user,uint _countToken) isOwner returns (bool){

        cashRegister[_user] +=_countToken;
        if(cashRegister[_user]==0)return false;
        return true;
    }

    function doClick(address _advertiser,address _webMaster,uint _costOfClick) isOwner
    returns(bool){
        //todo проверка цены за клик
        //todo модификаторы доступа
         //проверка есть ли бабки на балансе
        if (cashRegister[_advertiser] < _costOfClick){
            LogClick(_advertiser,false);
            return false;

        }
        cashRegister[_advertiser]-=_costOfClick;
        cashRegister[_webMaster]+=_costOfClick;
        return increaseCountofClick(_advertiser,_webMaster);

    }

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

     function balanceOf(address _user) constant returns (uint256) {
         LogBalance(_user,cashRegister[_user]);
        return cashRegister[_user];
    }

    modifier isOwner {
        if (msg.sender == owner)
        _;
    }
}
