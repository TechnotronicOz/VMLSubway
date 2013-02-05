#Collections of messages that belong to a frame
Stream = Backbone.Collection.extend
	model: Message

	unread: ->
		@filter((msg) ->
			msg.get('unread')
		)

	unreadMentions: ->
		@filter((msg) ->
			msg.get('unreadMention')
		)


#All channels/private message chats a user has open
WindowList = Backbone.Collection.extend
	model: ChatWindow

	initialize: ->
		@bind 'add', @setActive, @

	getByName: (name) ->
		@find((chat) ->
			chat.get('name') is name
		)

	getActive: ->
		@find((chat) ->
			chat.get('active') is true
		)

	setActive: (selected) ->
		# this is here for private messages
		name = selected.get('name')
		if name[0] isnt '#' and name isnt 'status' and selected.stream.models.lenght < 1
			selected.set active: false
			return
		@each((chat) ->
			chat.set active: false;
		)
		selected.set active: true
		selected.view.render()

	# Restrict to a certain type of chat window
	byType: (type) ->
		@filter((chat) ->
			chat.get('type') isnt type
		)

	unreadCount: ->
		channels = @byType('channel')
		pms = @byType('pm')
		count = 0
		count = channels.reduce((prev, chat) ->
			prev + chat.get('unreadMentions')
		, 0)
		count += pms.reduce((prev, chat) ->
			prev + chat.get('unread')
		, 0)
		return count

	unreadByChannel: ->
		channels = @byType('channel')
		pms = @byType('pm')
		$.each(channels, (key, chat) ->
			windowCounts[chat.get('name')] = chat.get('unread')
		)

		$.each(pms, (key, pm) ->
			windowCounts[pm.get('name')] = pm.get('unread')
		)

		windowCounts


UserList = Backbone.Collection.extend
	model: User

	initialize: (channel) ->
		@channel = channel
		@view = new UserListView collection: @

	getByNick: (nick) ->
		@detect((user) ->
			user.get('nick') is nick
		)

	getUsers: ->
		users = @map((user) ->
			user.get('nick')
		)
		users
















