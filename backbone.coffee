# Backbone.coffee 0.9.2
  
  # Initial Setup
  # -------------

  # Save a reference to the global object (`window` in the browser, `global`
  # on the server).
  root = @

  # Save the previous value of the `Backbone` variable, so that it can be
  # restored later on, if `noConflict` is used.
  previousBackbone = root.Backbone

  # Create a local reference to slice/splice.
  slice = Array.prototype.slice
  splice = Array.prototype.splice

  # The top-level namespace. All public Backbone classes and modules will
  # be attached to this. Exported for both CommonJS and the browser.
  Backbone = if exports? then exports else root.Backbone = {}

  # Require Underscore, if we're on the server, and it's not already present.
  _ = if (!_ and require?) then require 'underscore' else root._

  # For Backbone's purposes, jQuery, Zepto, or Ender owns the `$` variable.
  $ = root.jQuery or root.Zepto or root.ender

  # Current version of the library. Keep in sync with `package.json`.
  Backbone.VERSION = '0.9.2'

  # For Backbone's purposes, jQuery, Zepto, or Ender owns the `$` variable.
  Backbone.setDomLibrary = (lib) -> $ = lib; return

  # Runs Backbone.js in *noConflict* mode, returning the `Backbone` variable
  # to its previous owner. Returns a reference to this Backbone object.
  Backbone.noConflict =  () -> root.Backbone = previousBackbone; @

  ### Turn on `emulateHTTP` to support legacy HTTP servers. Setting this option
      will fake `"PUT"` and `"DELETE"` requests via the `_method` parameter and
      set a `X-Http-Method-Override` header.
  ###
  Backbone.emulateHTTP = false;

  ### Turn on `emulateJSON` to support legacy servers that can't deal with direct
     `application/json` requests ... will encode the body as
     `application/x-www-form-urlencoded` instead and will send the model in a
     form param named `model`.
  ###
  Backbone.emulateJSON = false;

  # Backbone.Events
  # -----------------

  # Regular expression used to split event strings
  eventSplitter = /\s+/

  # A module that can be mixed in to *any object* in order to provide it with
  # custom events. You may bind with `on` or remove with `off` callback functions
  # to an event; `trigger`-ing an event fires all callbacks in succession.
  #
  #     object = {}
  #     _.extend object, Backbone.Events
  #     object.on 'expand' () -> alert 'expanded'
  #     object.trigger 'expand'
  #
  Events = Backbone.Events =

    # Bind one or more space separated events, `events`, to a `callback`
    # function. Passing `"all"` will bind the callback to all events fired.
    on: (events, callback, context) ->
        return @ if !callback
        events = events.split eventSplitter
        calls = if @._callbacks? then @._callbacks else @._callbacks = {}
        while event = events.shift()
          list = calls[event]
          node = if list then list.tail else {}
          node.next = tail = {}
          node.$prop = $prop for $prop in [context, callback]
          calls[event] =
            tail: tail
            next: if list then list.next else nod
        @

    # Remove one or many callbacks. If `context` is null, removes all callbacks
    # with that function. If `callback` is null, removes all callbacks for the
    # event. If `events` is null, removes all bound callbacks for all events.
    off: (events, callback, context) ->

      # No events, or removing *all* events.
      return @ if !(calls = @._callbacks)
      unless events or callback or context
        delete @._callbacks
        @

      events = if events? then events.split eventSplitter else _.keys(calls)
      
      # Loop through the callback list, splicing where appropriate.
      while event = events.shift()
        unless (list = calls[event] and (callback or context))
          delete calls[event]
          continue

      for i in [list.length - 2...0] by -2
        list.splice i, 2 unless (callback and list[i] isnt callback or 
                                   context and list[i + 1] isnt context)

      @

    # Trigger one or many events, firing all bound callbacks. Callbacks are
    # passed the same arguments as `trigger` is, apart from the event name
    # (unless you're listening on `"all"`, which will cause your callback to
    # receive the true name of the event as the first argument).
    trigger: (events) ->
      @ unless (calls = @._callbacks)

      rest = []
      events = events.split eventSplitter

      # Fill up `rest` with the callback arguments.  Since we're only copying
      # the tail of `arguments`, a loop is much faster than Array#slice.
      rest[i - 1] = arguments[i] for i in [1..arguments.length]
      
      # For each event, walk through the list of callbacks twice, first to
      # trigger the event, then to trigger any `"all"` callbacks.
      while event = events.shift()
        all = all.slice() if all = calls.all
        list = list.slice() if list = calls[event]
      
      # Execute event callbacks.
      list[i].apply list[i + 1] || @, rest for i in [0..list.length] by 2 if list
      
      # Execute "all" callbacks.
      if (all)
        args = [event].concat rest
        all[i].apply all[i + 1] || @, args for i in [0..all.length] by 2
      @

    # Aliases for backwards compatibility.
    bind: @.on
    unbind: @.off


  # Backbone.Model
  # --------------

  # Create a new model, with defined attributes. A client id (`cid`)
  # is automatically generated and assigned for you.
  Backbone.Model = Model
  class Model
    
    attributes = {}
    _escapedAttributes = {}
    cid = _.uniqueId 'c'
    changed = null
    _silent = null
    _pending = null



    constructor: (attributes, options) ->
      attributes = {} unless attributes
      @.collection = options.collection if options and options.collection
      attributes = @.parse attributes if options and options.parse
      attributes = _.extend {}, defaults, attributes if defaults = getValue @, 'defaults'
      @.set attributes, {silent: true}
      # Reset change tracking
      [@.changed, @._silent, @._pending] = [{},{},{}]
      @._previousAttributes = _.clone @.attributes
      @.initialize.apply @, arguments

    initialize: () -> 

    toJSON: (options) -> _.clone @.attributes

    sync: () -> Backbone.sync.apply @, arguments

    get: (attr) -> @.attributes[attr]

    escape: (attr) ->
      return html if html = @._escapedAttributes[attr]
      val = @.get attr
      return @._escapedAttributes[attr] = _.escape if val? then '' + val else ''

    has: (attr) -> (@.get attr) isnt null

    set: (key, value, options) ->

      if (_.isObject key) or (key is null)
        attrs = key
        options = value
      else
        attrs = {}
        attrs[key] = value

      @

  # Attach Events to Model prototype
  _.extend Model::, Events
    

  return

