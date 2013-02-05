Message = Backbone.Model.extend
	defaults:
		type: 'message'

	initialize: ->
		@set text: @get('raw') if @get('raw')

		if @get('type') is 'message' and @get('raw').search('\\b' + irc.me.get('nick') + '\\b') isnt -1 then @set mention: true

	parse: (text) ->
		nick = @get('sender') or @collection.channel.get('name')
		result = utils.linkify text
		results = utils.mentions(result) if nick isnt irc.me.get('nick')
		return result


ChatWindow = Backbone.Model.extend
	defaults:
		type: 'channel'
		active: true,
		unread: 0,
		unreadMentions: 0

	initialize: ->
		@stream = new Stream()
		@stream.bind 'add', @setUnread, @
		@stream.channel = @
		@view = new ChatView model: @

	part: ->
		@destroy()

	setUnread: (msg) ->
		return if @get('active')
		signal = false
		if msg.get('type') is 'message' or msg.get('type') is 'pm' then @set unread: @get('unread') + 1
		signal = true if @get('type') is 'pm'
		if msg.get('mention')
			@set unreadMentions: @get('unreadMentions') + 1
			signal = true
		@trigger('forMe', 'message') if signal


User = Backbone.Model.extend
	initialize: ->

	defaults:
		opStatus: ''