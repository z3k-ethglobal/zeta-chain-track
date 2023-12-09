// SPDX-License-Identifier: BUSL-1.1
pragma solidity 0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./IPriceFeed.sol";

/**
 * @title WBTC price feed
 * @notice A custom price feed that calculates the price for WBTC / USD
 * @author Compound
 */
contract priceWRTbtc is IPriceFeed {
    /** Custom errors **/
    error BadDecimals();
    error InvalidInt256();

    /// @notice Version of the price feed
    uint public constant override version = 1;

    /// @notice Description of the price feed
    string public constant override description = "Custom price feed for WBTC / USD";

    /// @notice Number of decimals for returned prices
    uint8 public override decimals = 8;

    /// @notice Chainlink BTC / USD price feed
    address public immutable BTCToUSDPriceFeed;
    address public tokenToUSDPriceFeed;

    /**
     * @notice Construct a new WBTC / USD price feed
     * @param BTCToUSDPriceFeed_ The address of the BTC / USD price feed to fetch prices from
     * @param decimals_ The number of decimals for the returned prices
     **/
    constructor(address BTCToUSDPriceFeed_, uint8 decimals_) {
        BTCToUSDPriceFeed = BTCToUSDPriceFeed_;
    }

    function set_tokenToUSDPriceFeed(address a) public {
        tokenToUSDPriceFeed = a;
    }

    function set_decimals(uint8 d) public {
        require(d<= 18);
        decimals = d;
    } 

        /**
     * @notice WBTC price for the latest round
     * @return roundId Round id from the BTC / USD price feed
     * @return answer Latest price for WBTC / USD
     * @return startedAt Timestamp when the round was started; passed on from the BTC / USD price feed
     * @return updatedAt Timestamp when the round was last updated; passed on from the BTC / USD price feed
     * @return answeredInRound Round id in which the answer was computed; passed on from the BTC / USD price feed
     **/

    function latestRoundData() override external view returns (uint80, int256, uint256, uint256, uint80) {
        int combinedScale = signed256(10 ** (AggregatorV3Interface(tokenToUSDPriceFeed).decimals() + AggregatorV3Interface(BTCToUSDPriceFeed).decimals()));
        int priceFeedScale = int256(10 ** decimals);
        (, int256 tokenToUSDPrice, , , ) = AggregatorV3Interface(tokenToUSDPriceFeed).latestRoundData();
        (uint80 roundId_, int256 BTCToUSDPrice, uint256 startedAt_, uint256 updatedAt_, uint80 answeredInRound_) = AggregatorV3Interface(BTCToUSDPriceFeed).latestRoundData();

        // We return the round data of the BTC / USD price feed because of its shorter heartbeat (1hr vs 24hr)
        if (tokenToUSDPrice <= 0 || BTCToUSDPrice <= 0) return (roundId_, 0, startedAt_, updatedAt_, answeredInRound_);

        int256 price = tokenToUSDPrice * BTCToUSDPrice * priceFeedScale / combinedScale;
        return (roundId_, price, startedAt_, updatedAt_, answeredInRound_);
    }

    function signed256(uint256 n) internal pure returns (int256) {
        if (n > uint256(type(int256).max)) revert InvalidInt256();
        return int256(n);
    }
}