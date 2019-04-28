/* solhint-disable no-empty-blocks */
pragma solidity 0.5.7;

import "openzeppelin-solidity/contracts/token/ERC20/ERC20.sol";
import "openzeppelin-solidity/contracts/token/ERC20/ERC20Detailed.sol";


/**
 * @title User-friendly ERC20 token with gas-less transfers
 * @dev This contract is the base of our token
 */
contract Meerkoin is ERC20, ERC20Detailed {
    /* The details of our token */
    string private _name = "Meerkoin";
    string private _symbol = "MEER";
    uint8 private _decimals = 18;

    /* Users will have to pay a fee to use meta functions */
    uint8 public fee = 1;

    /* We store the nonces here */
    mapping (address => uint256) public nonces;

    constructor() public ERC20Detailed(
        _name,
        _symbol,
        _decimals
    ) {
    }

    /**
     * @dev Buys tokens (payable)
     */
    function buyTokens() external payable {
        _mint(msg.sender, msg.value);
    }

    /**
     * @dev Sells tokens
     * @param amount The amount of tokens to be sold
     */
    function sellTokens(uint256 amount) external {
        _burn(msg.sender, amount);
        msg.sender.transfer(amount);
    }

    /**
     * @dev Transfers tokens using a meta-transaction
     * @param signature The signature of the address requesting a transfer
     * @param to The address receiving the tokens
     * @param amount The amount of tokens to be transferred
     * @param nonce The current nonce for the original address
     */
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

    /**
     * @dev Creates an hash for a meta transfer
     * @param to The address receiving the tokens
     * @param amount The amount of tokens to be transferred
     * @param nonce The current nonce for the original address
     * @return The hash for the meta transfer
     */
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
