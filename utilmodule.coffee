utilmodule = {name: "utilmodule"}
############################################################
#region printLogFunctions
log = (arg) ->
    if allModules.debugmodule.modulesToDebug["utilmodule"]?  then console.log "[utilmodule]: " + arg
    return
ostr = (obj) -> JSON.stringify(obj, null, 4)
olog = (obj) -> log "\n" + ostr(obj)
print = (arg) -> console.log(arg)
#endregion


############################################################
situations = null

############################################################
utilmodule.initialize = () ->
    log "utilmodule.initialize"
    situationAnalyzer = allModules.situationanalyzermodule
    situations = situationAnalyzer.situations
    return

############################################################
#region internalFunctions
sellToBuy = (sellOrder) ->
    buyOrder = {}
    
    sellPrice = parseFloat(sellOrder.price)
    sellVolume = parseFloat(sellOrder.volume)

    buyOrder.inverted = true unless sellOrder.inverted
    buyOrder.id = sellOrder.id
    buyOrder.type = "buy"
    buyOrder.price = 1.0 / sellPrice
    buyOrder.volume = sellPrice * sellVolume
    return buyOrder

############################################################
buyToSell = (buyOrder) ->
    sellOrder = {}
    
    buyPrice = parseFloat(buyOrder.price)
    buyVolume = parseFloat(buyOrder.volume)
    
    sellOrder.inverted = true unless buyOrder.inverted
    sellOrder.id = buyOrder.id
    sellOrder.type = "sell"
    sellOrder.price = 1.0 / buyOrder.price
    sellOrder.volume = buyPrice * buyVolume
    return sellOrder

############################################################
buyIdeaIsAffordable = (idea) ->
    exchange = idea.exchange
    assetPair = idea.assetPair
    assets = assetPair.split("-")
    assetSituation = situations[exchange].assets[assets[1]]
    available = assetSituation.totalVolume - assetSituation.lockedVolume
    availableVolume = available / idea.price
    if idea.volume > availableVolume
        # log "buy Idea was not affordable - this is stupid!"
        return false
    return true

sellIdeaIsAffordable = (idea) ->
    exchange = idea.exchange
    assetPair = idea.assetPair
    assets = assetPair.split("-")
    assetSituation = situations[exchange].assets[assets[0]]
    available = assetSituation.totalVolume - assetSituation.lockedVolume
    if idea.volume > available
        # log "sell Idea was not affordable - this is stupid!"
        return false
    return true

#endregion


############################################################
#region exposedFunctions
utilmodule.invertTicker = (ticker) ->
    inverted = {}
    inverted.askPrice = 1.0 / ticker.bidPrice
    inverted.bidPrice = 1.0 / ticker.askPrice
    inverted.closingPrice = 1.0 / ticker.closingPrice
    ## TODO check if this calculation is even accurate
    # inverted.dAskPrice = ticker.dBidPrice / ticker.bidPrice
    # inverted.dBidPrice = ticker.dAskPrice / ticker.askPrice
    # inverted.dClosingPrice = ticker.dClosingPrice / ticker.closingPrice
    return inverted


utilmodule.invertOrder = (order) ->
    if order.type == "sell" then return sellToBuy(order)
    if order.type == "buy" then return buyToSell(order)
    return inverted


utilmodule.ideaIsAffordable = (idea) ->
    if idea.type == "buy" then return buyIdeaIsAffordable(idea)
    if idea.type == "sell" then return sellIdeaIsAffordable(idea)
    return


############################################################
#region getLatestPrices
utilmodule.getLatestClosingPrice = (exchange, assetPair) ->
    assets = assetPair.split("-")
    exchangeSituation = situations[exchange]
    assetSituation = exchangeSituation.assets[assets[0]]
    prices = assetSituation.pricesTo[assets[1]]
    return prices.closingPrice

utilmodule.getLatestBidPrice = (exchange, assetPair) ->
    assets = assetPair.split("-")
    exchangeSituation = situations[exchange]
    assetSituation = exchangeSituation.assets[assets[0]]
    prices = assetSituation.pricesTo[assets[1]]
    return prices.bidPrice

utilmodule.getLatestAskPrice = (exchange, assetPair) ->
    assets = assetPair.split("-")
    exchangeSituation = situations[exchange]
    assetSituation = exchangeSituation.assets[assets[0]]
    prices = assetSituation.pricesTo[assets[1]]
    return prices.askPrice

#endregion

############################################################
#region basics
utilmodule.plusPercentFactor = (percent) -> 0.01 * (100 + percent)

############################################################
utilmodule.getMinDif = (precision) ->
    return 0 if precision == 0
    zero = 0.0
    minDif = zero.toFixed(precision-1) + 1
    return parseFloat(minDif)

#endregion

#endregion

module.exports = utilmodule