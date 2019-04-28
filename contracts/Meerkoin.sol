/* solhint-disable no-empty-blocks */
pragma solidity 0.5.7;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";


/**
 * @title An amazing project called Meerkoin
 * @dev This contract is the base of our project
 */
contract Meerkoin is ERC20, ERC20Detailed {
    string private _name = "Meerkoin";
    string private _symbol = "MEER";
    uint8 private _decimals = 18;

    uint8 public fee = 1;

    mapping (address => uint256) public nonces;

    constructor() public ERC20Detailed(
        _name,
        _symbol,
        _decimals
    ) {
    }

    function buyTokens() external payable {
        _mint(msg.sender, msg.value);
    }

    function sellTokens(uint256 amount) external {
        _burn(msg.sender, amount);
        msg.sender.transfer(amount);
    }

    function metaTransfer(bytes memory signature, address to, uint256 amount, uint256 nonce) public {
        bytes32 hash = metaTransferHash(to, amount, nonce);
        address signer = getSigner(hash, signature);

        require(signer != address(0), "Cannot get signer");
        require(nonce == nonces[signer], "Nonce is invalid");

        nonces[signer] += 1;

        uint256 reward = SafeMath.mul(
            SafeMath.div(amount, 100),
            fee
        );

        _transfer(
            signer,
            to,
            SafeMath.sub(amount, reward)
        );

        _transfer(signer, msg.sender, reward);
    }

    function metaTransferHash(address to, uint256 amount, uint256 nonce) public view returns (bytes32) {
        return keccak256(abi.encodePacked(address(this), "metaTransfer", to, amount, nonce));
    }

    /**
     * @dev Gets the signer of an hash using the signature
     * @param hash The hash to check
     * @param signature The signature to use
     * @return The address of the signer or 0x0 address is something went wrong
     */
    function getSigner(bytes32 hash, bytes memory signature) public pure returns (address) {
        bytes32 r;
        bytes32 s;
        uint8 v;

        if (signature.length != 65) {
            return address(0);
        }

        /* solhint-disable-next-line no-inline-assembly */
        assembly {
            r := mload(add(signature, 32))
            s := mload(add(signature, 64))
            v := byte(0, mload(add(signature, 96)))
        }

        if (v < 27) {
            v += 27;
        }

        if (v != 27 && v != 28) {
            return address(0);
        } else {
            return ecrecover(keccak256(
                abi.encodePacked("\x19Ethereum Signed Message:\n32", hash)
            ), v, r, s);
        }
    }
}
