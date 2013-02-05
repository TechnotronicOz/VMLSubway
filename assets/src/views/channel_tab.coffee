ChannelTabView = Backbone.View.extend
	className: 'channel'

	events:
		'click': 'setActive'
		'click .close-button': 'close'

	initialize: ->
		@model.stream.bind 'add', @updateUnreadCounts, @
		@model.bind('destroy', @switchAndRemove, @).bind('change:active', @removeUnread, @)


	render: ->
		self = @
		tmpl = ich.channel({
			name: @model.get 'name'
			notStatus: ->
				self.model.get 'type' isnt 'status'
		})

		$(@el).html tmpl
		return @


	setActive: ->
		if not @model.get 'active' then irc.chatWindows.setActive @model
		$(@el).addClass('active').siblings().removeClass 'active'
		@removeUnread


	updateUnreadCounts: ->
		unread = @model.get 'unread'
		unreadMentions = @model.get 'unreadMentions'

		if unread > 0
			@$('.unread').text(unread).show()
		else
			@$('.unread').hide()

		if unreadMentions > 0
			@$('.unread-mentions').text(unreadMentions).show()
		else
			@$('.unread-mentions').hide()


	removeUnread: ->
		return if @model.get 'active' is false
		@$el.children('.unread, .unread-mentions').hide()
		@model.set unread: 0, unreadMentions: 0


	close: (e) ->
		e.stopPropagation()
		if @model.get 'type' is 'channel'
			irc.socket.emit 'part', @.model.get 'name'
		else
			irc.socket.emit 'part_pm', @model.get 'name'
			@model.destroy()


	switchAndRemove: ->
		$nextTab

		if $(@el).hasClass 'active'
			if $(@el).next.length
				$nextTab = $(@el).next()
			else
				$nextTab = $(@el).prev()

		@remove()
		$nextTab.click() if typeof($nextTab.click) is 'function'
