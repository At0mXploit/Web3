// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.31;

contract SimpleStorage {
  uint256 myfavoriteNumber;

  // uint256[] listOfFavoriteNumbers;

  struct Person {
    uint256 favoriteNumber;
    string name;
  }

  // Person public pat = Person({favoriteNumber: 7, name: "Pat"});

  Person[] public listOfPeople; // []

  // chelesa -> 222
  mapping(string => uint256) public nameToFavoriteNumber;

  // virtual will let other function override this function
  function store(uint256 _favoriteNumber) public virtual {
    myfavoriteNumber = _favoriteNumber;
  }

  // view and pure dont take transactions they only read state data but not modify

  function retrieve() public view returns(uint256) {
    return myfavoriteNumber;
  }

  // calldata -> Non changeable, memory -> changeable, storage
  // String, Array, Structs needs memory keyword

  function addPerson(string memory _name, uint256 _favoriteNumber) public {
    listOfPeople.push(Person(_favoriteNumber, _name));
    nameToFavoriteNumber[_name] = _favoriteNumber;
  }
}

