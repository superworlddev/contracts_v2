//SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

library Utils {
    // @dev trims the decimals to a certain substring and gives it back
    // @param takes in the string, and trims based on the decimal integer
    // @return returns the substring based on the decimal values.
    function truncateDecimals(string memory str, uint256 decimal)
        public
        pure
        returns (string memory)
    {
        uint256 decimalIndex = indexOfChar(str, bytes1("."), 0);
        bytes memory strBytes = bytes(str);
        uint256 length = strBytes.length;
        return (decimalIndex + decimal + 1 > length) ? substring(str, 0, length) : substring(str, 0, decimalIndex + decimal + 1);
    }

    // @dev standard substring method. Note that endIndex == 0 indicates the substring should be taken to the end of the string.
    // @param takes in a string, and a starting (included) and ending index (not included in substring).
    // @return substring
    function substring(
        string memory str,
        uint256 startIndex,
        uint256 endIndex
    ) public pure returns (string memory) {
        bytes memory strBytes = bytes(str);
        if (endIndex == 0) {
            endIndex = strBytes.length;
        }
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }

    // @dev gets the index of a certain character inside of a string; helper method
    // @param requires a string, a certain character, and the index to start checking from
    // @return returns the index of the character in the string
    function indexOfChar(string memory str, bytes1 char, uint256 startIndex) public pure returns (uint256) {
        bytes memory strBytes = bytes(str);
        uint256 length = strBytes.length;
        for (uint256 i = startIndex; i < length; i++) {
            if (strBytes[i] == char) {
                return i;
            }
        }
        return 0;
    }

    // @dev converts ASCII encoding into a string
    // @param bytes32 ASCII encoding
    // @return string version
    function bytes32ToString(bytes32 _dataBytes32)
        public
        pure
        returns (string memory)
    {
        bytes memory bytesString = new bytes(32);
        uint256 charCount = 0;
        uint256 j;
        for (j = 0; j < 32; j++) {
            // outscope declaration
            bytes1 char = bytes1(bytes32(uint256(_dataBytes32) * 2**(8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

    // @devs: Converts a number to a string literal of its hex representation (without the '0x' prefix)
    // @param a number
    // @return string literal of the number's hex
    function toHexString(uint256 value) public pure returns (string memory) {
        // Inspired by OraclizeAPI's implementation - MIT license
        // https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 16;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            uint256 digit = temp % 16;
            if (digit < 10) {
                buffer[index--] = bytes1(uint8(48 + digit));
            } else {
                buffer[index--] = bytes1(uint8(87 + digit));
            }
            temp /= 16;
        }
        return string(buffer);
    }

    // @dev provides the token id based on the coordinates(longitude and latitude) of the property
    // @param a longitude string and a latitude string
    // @return returns the token id as a 32 bit object, otherwise it returns a 0 as a hex if the lat and lon are empty
    function getTokenId(string memory lat, string memory lon)
        public
        pure
        returns (bytes32 tokenId)
    {
        if (bytes(lat).length == 0 || bytes(lon).length == 0) {
            return 0x0;
        }
        
        string memory geo = string(abi.encodePacked(lat, ",", lon));
        assembly {
            tokenId := mload(add(geo, 32))
        }
    }
    
    // @dev the opposite of the getTokenId, gives the lat and lon using tokenId
    // @param takes in a 32 bit tokenId object.
    // @return returns the latitude and longitude of a location
    function getGeoFromTokenId(bytes32 tokenId)
        public
        pure
        returns (
            string memory lat,
            string memory lon
        )
    {
        uint256 n = 32;
        while (n > 0 && tokenId[n-1] == 0) {
            n--;
        }
        bytes memory bytesArray = new bytes(n);
        for (uint256 i = 0; i < n; i++) {
            bytesArray[i] = tokenId[i];
        }
        string memory geoId = string(bytesArray);
        lat = getLat(geoId);
        lon = getLon(geoId);
    }
    
    // @dev gets the latitude of the token from a geoId
    // @param takes in a string of form "Lat,Lon" as a parameter
    // @return returns the str of the latitude
    function getLat(string memory str) public pure returns (string memory) {
        uint256 index = indexOfChar(str, bytes1(","), 0);
        return substring(str, 0, index);
    }

    // @dev gets the longitude of the token from a geoId
    // @param takes in a string of form "Lat,Lon" as a parameter
    // @return returns the str of the longitude
    function getLon(string memory str) public pure returns (string memory) {
        uint256 index = indexOfChar(str, bytes1(","), 0);
        return substring(str, index + 1, 0);
    }
}