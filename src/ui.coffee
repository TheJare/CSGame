# Simple UI widgets

class @UIWidget extends Go
    constructor: (@rect) ->
        super
        @disabled = false
        @interactive = false
        @hover = false
        return

    hittest: (x,y) ->
        @rect.contains x, y

    click: () ->

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
        @pushed = false
        @down = false
        return

    render: (ctx) ->
        ctx.font = @font
        ctx.fillStyle = "#808"
        ctx.fillRect @rect.x(), @rect.y(), @rect.w(), @rect.h()
        s = if @down or @hover then 1 else 0
        ctx.fillStyle = if IsArray @color then @color[s] else @color
        ctx.fillText @text, @rect.x(), @y
        return

class @UIScreen extends GoContainer
    constructor: ->
        @cursorx = 0
        @cursory = 0
        @lasthover = null
        super
        return

    cursor: (x,y) ->
        @cursorx = x
        @cursory = y
        if @lasthover?
            @lasthover.hover = false
            @lasthover = null
        # Call contained gos in descending order of layer they are in
        layers = (parseInt(k) for k,v of @layers)
        layers.sort()
        layers.reverse()
        for k in layers
            # Should optimize this to not traverse the entire @gos array
            for go in @gos
                if go.layer is k and go.interactive and not go.disabled
                    if go.hittest x, y
                        go.hover = true
                        @lasthover = go
        return @lasthover

    click: (x,y) ->
        if @lasthover?
            @lasthover.down = false
        widget = @cursor x,y
        if widget?
            widget.down = true

