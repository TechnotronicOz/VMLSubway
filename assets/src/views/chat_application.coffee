ChatApplicationView = Backbone.View.extend
	className: 'container-fluid'
	originalTitle: document.title

	initialize: ->
		irc.chatWindows.bind('change:unread', @showUnread, @).bind('change:unreadMentions', @showUnread, @)
		if @_supportedFormat
			@sounds:
				newPm: @_loadSound 'new-pm'
				message: @_loadSound 'msg'

		$(window).blur ( ->
			blurTimer = setTimeout ( ->
				activeChat = if irc.chatWindows.getActive() then irc.chatWindows.getActive() else activeChat
				activeChat.set 'active', false if activeChat and activeChat.set
			), 1000
		).focus( ->
			clearTimeout blurTimer
			activeChat.set 'active', true if activeChat and activeChat.set
		)
		@render()


	render: ->
		$('body').html($(@el)).html(ich.chat_application())

		if not irc.connected
			@overview = new OverviewView
		else
			@channelList = new ChannelListView
			$('.slide').css 'display', 'inline-block'

		return @


	showError: (text) ->
		$('#loading_image').remove()
		$('.btn').removeClass 'disabled'
		$('#home_parent').after(ich.alert type: 'alert-error', content: text).alert()


	renderUserBox: ->
		$('#user-box').html ich.user_box(irc.me.toJSON())
		$('#user-box .close-button').click ->
			irc.socket.emit 'disconnectedServer'


	showUnread: ->
		unreads = irc.chatWindows.unreadCount()
		if unreads > 0
			document.title = '(' + unreads + ')' + this.originalTitle
			if window.unity.connected
				window.unity.api.Launcher.setCount unreads
				window.unity.api.Launcher.setUrgent true
		else
			document.title = this.originalTitle
			if window.unity.connected
				window.unity.api.Launcher.clearCount()
				window.unity.api.Launcher.setUrgent false


	playSound: (type) ->
		@sounds && this.sounds[type].play()


	_loadSound: (name) ->
		a = new Audio()
		a.src = '/assets/sounds/' + name + '.' + this._supportedFormat()
		return a


	_supportedFormat: ->
		a = document.createElement 'audio'
		if not a.canPlayType
			return false
		else if not not a.canPlayType('audio/ogg; codecs="vorbis"').replace /no/, ''
			return 'ogg'
		else if not not a.canPlayType('audio/mepg;').replace /no/, ''
			return 'mp3'



