// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

interface AggregatorV3Interface {
    function decimals() external view returns (uint8);
    function description() external view returns (string memory);
    function version() external view returns (uint256);
    function getRoundData(uint80 _roundId) external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
    function latestRoundData() external view returns (
        uint80 roundId,
        int256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint80 answeredInRound
    );
}

/**
 * @title MultiCryptoPriceFeed - Sepolia 测试网版本
 * @dev 获取多种加密货币的实时价格
 * @notice 支持的币种：BTC, ETH, LINK, DAI, USDC（共5种）
 */
contract MultiCryptoPriceFeed {
    
    enum CryptoCurrency { 
        BTC,    // 0 - Bitcoin
        ETH,    // 1 - Ethereum
        LINK,   // 2 - Chainlink
        DAI,    // 3 - DAI Stablecoin (替换原来的 BNB)
        USDC    // 4 - USD Coin (保留，移除了 USDT)
    }
    
    mapping(CryptoCurrency => AggregatorV3Interface) public priceFeeds;
    mapping(CryptoCurrency => string) public currencySymbols;
    
    address public owner;
    
    // 更新5个币种
    uint8 public constant INITIALIZED_COUNT = 5;
    
    event PriceFeedAdded(CryptoCurrency currency, address feedAddress);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
    
    /**
     * @dev 构造函数：初始化 Sepolia 测试网的价格源
     */
    constructor() {
        owner = msg.sender;
        _initializeSepoliaFeeds();
        _initializeSymbols();
    }
    
    /**
     * @dev 初始化 Sepolia 测试网的价格源地址
     * 修改：BNB 替换为 DAI，移除 USDT
     */
    function _initializeSepoliaFeeds() private {
        // BTC/USD - Sepolia
        priceFeeds[CryptoCurrency.BTC] = AggregatorV3Interface(
            0x1b44F3514812d835EB1BDB0acB33d3fA3351Ee43
        );
        
        // ETH/USD - Sepolia
        priceFeeds[CryptoCurrency.ETH] = AggregatorV3Interface(
            0x694AA1769357215DE4FAC081bf1f309aDC325306
        );
        
        // LINK/USD - Sepolia
        priceFeeds[CryptoCurrency.LINK] = AggregatorV3Interface(
            0xc59E3633BAAC79493d908e63626716e204A45EdF
        );
        
        // DAI/USD - Sepolia 
        priceFeeds[CryptoCurrency.DAI] = AggregatorV3Interface(
            0x14866185B1962B63C3Ea9E03Bc1da838bab34C19
        );
        
        // USDC/USD - Sepolia
        priceFeeds[CryptoCurrency.USDC] = AggregatorV3Interface(
            0xA2F78ab2355fe2f984D808B5CeE7FD0A93D5270E
        );

    }
    
    /**
     * @dev 初始化代币符号
     * 修改：BNB → DAI，移除 USDT
     */
    function _initializeSymbols() private {
        currencySymbols[CryptoCurrency.BTC] = "BTC";
        currencySymbols[CryptoCurrency.ETH] = "ETH";
        currencySymbols[CryptoCurrency.LINK] = "LINK";
        currencySymbols[CryptoCurrency.DAI] = "DAI";    
        currencySymbols[CryptoCurrency.USDC] = "USDC";
    }
    
    /**
     * @dev 获取单个加密货币的最新价格
     * @param currency 加密货币枚举
     * @return price 原始价格（未格式化）
     */
    function getLatestPrice(CryptoCurrency currency) public view returns (int) {
        AggregatorV3Interface priceFeed = priceFeeds[currency];
        require(address(priceFeed) != address(0), "Price feed not configured for this currency");
        
        (
            /* uint80 roundID */,
            int price,
            /* uint startedAt */,
            /* uint timeStamp */,
            /* uint80 answeredInRound */
        ) = priceFeed.latestRoundData();
        
        require(price > 0, "Invalid price data");
        return price;
    }
    
    /**
     * @dev 获取价格和详细信息
     * @param currency 加密货币枚举
     * @return rawPrice 原始价格
     * @return formattedPrice 格式化后的价格（18位小数）
     * @return decimals 该价格源的小数位数
     */
    function getPriceWithDetails(CryptoCurrency currency) 
        public 
        view 
        returns (
            int rawPrice,
            uint256 formattedPrice,
            uint8 decimals
        ) 
    {
        AggregatorV3Interface priceFeed = priceFeeds[currency];
        require(address(priceFeed) != address(0), "Price feed not configured for this currency");
        
        rawPrice = getLatestPrice(currency);
        decimals = priceFeed.decimals();
        formattedPrice = uint256(rawPrice) * (10 ** (18 - decimals));
        
        return (rawPrice, formattedPrice, decimals);
    }
    
    /**
     * @dev 批量获取多种加密货币价格
     * @param currencies 加密货币枚举数组
     * @return prices 对应的价格数组
     */
    function getMultiplePrices(CryptoCurrency[] memory currencies) 
        public 
        view 
        returns (int[] memory prices) 
    {
        prices = new int[](currencies.length);
        
        for (uint i = 0; i < currencies.length; i++) {
            prices[i] = getLatestPrice(currencies[i]);
        }
        
        return prices;
    }
    
    /**
     * @dev 获取所有已配置加密货币的完整价格信息
     * @return symbols 代币符号数组
     * @return prices 价格数组
     * @return decimalsArray 小数位数组
     */
    function getAllPrices() 
        public 
        view 
        returns (
            string[] memory symbols,
            int[] memory prices,
            uint8[] memory decimalsArray
        ) 
    {
        //5个币种
        symbols = new string[](INITIALIZED_COUNT);
        prices = new int[](INITIALIZED_COUNT);
        decimalsArray = new uint8[](INITIALIZED_COUNT);
        
        // 遍历所有已初始化的币种
        for (uint8 i = 0; i < INITIALIZED_COUNT; i++) {
            CryptoCurrency currency = CryptoCurrency(i);
            
            // 双重检查价格源是否存在
            require(address(priceFeeds[currency]) != address(0), "Price feed not initialized");
            
            symbols[i] = currencySymbols[currency];
            
            // 添加错误处理
            try this.getLatestPrice(currency) returns (int price) {
                prices[i] = price;
            } catch {
                prices[i] = 0; // 如果获取失败，返回 0
            }
            
            decimalsArray[i] = priceFeeds[currency].decimals();
        }
        
        return (symbols, prices, decimalsArray);
    }
    
    /**
     * @dev 获取价格源的描述信息
     * @param currency 加密货币枚举
     * @return 价格源的描述
     */
    function getPriceFeedDescription(CryptoCurrency currency) public view returns (string memory) {
        AggregatorV3Interface priceFeed = priceFeeds[currency];
        require(address(priceFeed) != address(0), "Price feed not configured for this currency");
        
        return priceFeed.description();
    }
    
    /**
     * @dev 添加或更新价格源（仅所有者可调用）
     * @param currency 加密货币枚举
     * @param feedAddress 价格源合约地址
     */
    function setPriceFeed(CryptoCurrency currency, address feedAddress) public onlyOwner {
        require(feedAddress != address(0), "Invalid feed address");
        priceFeeds[currency] = AggregatorV3Interface(feedAddress);
        emit PriceFeedAdded(currency, feedAddress);
    }
    
    /**
     * @dev 设置代币符号（仅所有者可调用）
     * @param currency 加密货币枚举
     * @param symbol 代币符号
     */
    function setCurrencySymbol(CryptoCurrency currency, string memory symbol) public onlyOwner {
        currencySymbols[currency] = symbol;
    }
    
    /**
     * @dev 获取真实价格（考虑小数位）
     * @param currency 加密货币枚举
     * @return 真实价格（18位小数）
     */
    function getRealPrice(CryptoCurrency currency) public view returns (uint256) {
        (/* int rawPrice */, uint256 formattedPrice, /* uint8 decimals */) = getPriceWithDetails(currency);
        return formattedPrice;
    }
    
    /**
     * @dev 计算两种加密货币之间的汇率
     * @param fromCurrency 源货币
     * @param toCurrency 目标货币
     * @return 汇率（18位小数）
     */
    function getExchangeRate(CryptoCurrency fromCurrency, CryptoCurrency toCurrency) 
        public 
        view 
        returns (uint256) 
    {
        (int fromPrice, , uint8 fromDecimals) = getPriceWithDetails(fromCurrency);
        (int toPrice, , uint8 toDecimals) = getPriceWithDetails(toCurrency);
        
        require(fromPrice > 0 && toPrice > 0, "Prices must be positive");
        
        uint256 rate = (uint256(fromPrice) * (10 ** toDecimals) * 1e18) / (uint256(toPrice) * (10 ** fromDecimals));
        
        return rate;
    }
    
    /**
     * @dev 测试所有价格源是否正常工作
     * @return working 布尔数组，表示每个价格源是否工作正常
     */
    function testAllPriceFeeds() external view returns (bool[] memory working) {
        working = new bool[](INITIALIZED_COUNT);
        
        for (uint8 i = 0; i < INITIALIZED_COUNT; i++) {
            CryptoCurrency currency = CryptoCurrency(i);
            
            if (address(priceFeeds[currency]) == address(0)) {
                working[i] = false;
                continue;
            }
            
            try this.getLatestPrice(currency) returns (int price) {
                working[i] = price > 0;
            } catch {
                working[i] = false;
            }
        }
        
        return working;
    }
    
    /**
     * @dev 获取当前网络的 Chain ID（用于验证部署网络）
     * @return Chain ID (Sepolia = 11155111)
     */
    function getChainId() external view returns (uint256) {
        return block.chainid;
    }
    
    /**
     * @dev 获取所有支持的币种列表
     * @return 币种符号数组
     */
    function getSupportedCurrencies() external view returns (string[] memory) {
        string[] memory currencies = new string[](INITIALIZED_COUNT);
        
        for (uint8 i = 0; i < INITIALIZED_COUNT; i++) {
            currencies[i] = currencySymbols[CryptoCurrency(i)];
        }
        
        return currencies;
    }
}