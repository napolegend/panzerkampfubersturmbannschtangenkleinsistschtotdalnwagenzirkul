//@version=5
// Copyright (c) 2023 napolegend Apache 2.0
indicator('Chandelier UND EMA Exit', shorttitle='A. Hit of price action', overlay=true)

length = input(title='ATR Period', defval=22)
mult = input.float(title='ATR Multiplier', step=0.1, defval=3.0)
showLabels = input(title='Show Buy/Sell Labels ?', defval=true)
useClose = input(title='Use Close Price for Extremums ?', defval=true)
highlightState = input(title='Highlight State ?', defval=true)
len = input.int(200, minval=1, title='Length')
src = input(close, title='Source')
offset = input.int(title='Offset', defval=0, minval=-500, maxval=500)
out = ta.ema(src, len)
plot(out, title='EMA', color=color.new(color.yellow, 0), offset=offset)

atr = mult * ta.atr(length)

longStop = (useClose ? ta.highest(close, length) : ta.highest(length)) - atr
longStopPrev = nz(longStop[1], longStop)
longStop := close[1] > longStopPrev ? math.max(longStop, longStopPrev) : longStop

shortStop = (useClose ? ta.lowest(close, length) : ta.lowest(length)) + atr
shortStopPrev = nz(shortStop[1], shortStop)
shortStop := close[1] < shortStopPrev ? math.min(shortStop, shortStopPrev) : shortStop

var int dir = 1
dir := close > shortStopPrev ? 1 : close < longStopPrev ? -1 : dir

var color longColor = color.green
var color shortColor = color.red

longStopPlot = plot(dir == 1 ? longStop : na, title='Long Stop', style=plot.style_linebr, linewidth=2, color=color.new(longColor, 0))
buySignal = dir == 1 and dir[1] == -1
plotshape(buySignal ? longStop : na, title='Long Stop Start', location=location.absolute, style=shape.circle, size=size.tiny, color=color.new(longColor, 0))
plotshape(buySignal and showLabels ? longStop : na, title='Buy Label', text='Buy', location=location.absolute, style=shape.labelup, size=size.tiny, color=color.new(longColor, 0), textcolor=color.new(color.white, 0))

shortStopPlot = plot(dir == 1 ? na : shortStop, title='Short Stop', style=plot.style_linebr, linewidth=2, color=color.new(shortColor, 0))
sellSignal = dir == -1 and dir[1] == 1
plotshape(sellSignal ? shortStop : na, title='Short Stop Start', location=location.absolute, style=shape.circle, size=size.tiny, color=color.new(shortColor, 0))
plotshape(sellSignal and showLabels ? shortStop : na, title='Sell Label', text='Sell', location=location.absolute, style=shape.labeldown, size=size.tiny, color=color.new(shortColor, 0), textcolor=color.new(color.white, 0))

midPricePlot = plot(ohlc4, title='', style=plot.style_circles, linewidth=0, display=display.none, editable=false)

longFillColor = highlightState ? dir == 1 ? longColor : na : na
shortFillColor = highlightState ? dir == -1 ? shortColor : na : na
fill(midPricePlot, longStopPlot, title='Long State Filling', color=longFillColor, transp=90)
fill(midPricePlot, shortStopPlot, title='Short State Filling', color=shortFillColor, transp=90)

changeCond = dir != dir[1]
alertcondition(changeCond, title='Alert: CE Direction Change', message='Chandelier Exit has changed direction!')
alertcondition(buySignal, title='Alert: CE Buy', message='Chandelier Exit Buy!')
alertcondition(sellSignal, title='Alert: CE Sell', message='Chandelier Exit Sell!')

