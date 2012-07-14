# Simple UI widgets

class @UIWidget extends Go
    constructor: (@rect) ->
        super
        @disabled = false
        @interactive = false
        @hovered = false
        @clicked = false
        return

    hittest: (x,y) ->
        @rect.contains x, y

    hover: (b) ->
        @hovered = b
        return

    click: (b) ->
        @clicked = b
        return

class @UITextButton extends UIWidget
    constructor: (ctx, x, @y, @text, font, size, color) ->
        @color = color ? "white"
        @font = "#{ size }px " + font
        ctx.font = @font
        w = (ctx.measureText text).width
        h = size
        topy = y - size/1.2
        x -= w/2 # always centered
        super new Rect [x, topy, x+w, topy+h]
        @interactive = true
        return

    render: (ctx) ->
        ctx.font = @font
        ctx.fillStyle = "#808"
        ctx.fillRect @rect.x(), @rect.y(), @rect.w(), @rect.h()
        if IsArray @color
            s = if @clicked then 2 else if @hovered then 1 else 0
            s = Clamp(s, 0, @color.length)
            ctx.fillStyle = @color[s]
        else
            ctx.fillStyle = @color
        ctx.fillText @text, @rect.x(), @y
        return

class @UIScreen extends GoContainer
    constructor: ->
        @cursorx = 0
        @cursory = 0
        @lasthover = null
        @lastclick = null
        super
        return

    findWidget: (x,y) ->
        # Call contained gos in descending order of layer they are in
        layers = (parseInt(k) for k,v of @layers)
        layers.sort()
        layers.reverse()
        for k in layers
            # Should optimize this to not traverse the entire @gos array
            for go in @gos
                if go.layer is k and go.interactive and not go.disabled
                    if go.hittest x, y
                        return go
        return null

    cursor: (x,y) ->
        @cursorx = x
        @cursory = y
        prevWidget = @lasthover
        curWidget = @findWidget x,y
        if prevWidget? and prevWidget != curWidget
            prevWidget.hover(false)
        if curWidget?
            curWidget.hover(true)
        @lasthover = curWidget
        return curWidget

    click: (x,y, b) ->
        prevWidget = @lastclick
        curWidget = @cursor x,y
        if prevWidget? and (not b or prevWidget != curWidget)
            prevWidget.click(false)
        if curWidget? and b
            curWidget.click(true)
        @lastclick = if b then curWidget else null
        return @lastclick

