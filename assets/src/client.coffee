window.irc:
	socket: io.connect null, port: PORT
	chatWindows: new WindowList()
	connected: false
	loggedIn: false

window.unity:
	api: null
	connected: false

$( ->
	irc.appView = new ChatApplicationView()

	try
		window.unity.api = external.getUnityObject 1.0
		window.unity.init(
			window.unity.connected = true
		)
	catch e
		window.unity.api = null


	$(window).bind 'beforeunload', ->
		return null if not window.irc.connected or window.irc.loggedIn
		return "If you leave, you'll be signed out"

	irc.socket.emit 'getDatabaseState', {}

	irc.socket.on 'databaseState', (data) ->
		$('#login, #register').hide() if data.state is 0


	irc.socket.on 'registered', (data) ->
		window = irc.chatWindows.getByName 'status'
		irc.socket.emit 'getNick', {}
		irc.connected = true
		if window is undefined
			irc.appView.render()
			irc.chatWindows.add name: 'status', type: 'status'
		else
			irc.appView.renderUserBox()

		irc.me.set 'nick', data.message.args[0]

	irc.socket.on 'login_success', (data) ->
		if data.exists then irc.socket.emit 'connect', {} else irc.appView.overview.render currentTarget: {id: "connection"}

	irc.socket.on 'disconnect', ->
		alert('You were disconnected from the server.')
		$('.container-fluid').css
			opacity: '0.5'
			filter:	'blur(5px)'
			'-webkit-filter': 'blur(5px)'

	irc.socket.on 'register_success', (data) ->
		window.irc.loggedIn = true
		irc.appView.overview.render currentTarget: {id: "connection"}

	irc.socket.on 'restore_connection', (data) ->
		irc.me = new User nick: data.nick, server: data.server
		irc.connected = true
		irc.appView.render()
		irc.appView.renderUserBox()
		irc.chatWindows.add name: 'status', type: 'status'
		$.each data.channels, (key, value) ->
			chanName = value.serverName.toLowerCase()
			if chanName[0] is '#'
				irc.chatWindows.add name: chanName, initial: true
			else
				irc.chatWindows.add name: chanName, type: 'pm', initial: true
			channel = irc.chatWindows.getByName(chanName)
			channelTabs = irc.appView.channelList.channelTabs
			channelTab = channelTabs[channelTabs.length-1]
			channel.set
				topic: value.topic
				unread: value.unread_messages
				unreadMentions: value.unread_mentions
			channelTab.updateUnreadCounts()
			if chanName[0] is = '#'
				channel.userList = new UserList channel
				$.each value.users, (user, role) ->
					channel.userList.add nick: user, role: role, idle: 0, user_status: 'idle', activity: ''
				irc.socket.emit 'getOldMessages', channelName: chanName, skip: 0, amount: 50
			else
				irc.socket.emit 'getOldMessages', channelName: chanName, skip: 0, amount: 50
				channel.stream.add new Message sender:'', raw:''

		$('.channel:first').click()
	# --> End

	irc.socket.on 'notice', (data) ->
		status = irc.chatWindows.getByName('status')
		if status is undefined
			irc.connected = true
			irc.appView.render()
			irc.chatWindows.add name: 'status', type: 'status'
			status = irc.chatWindows.getByName('status')
		sender = if data.nick isnt undefined then data.nick else 'notice'
		status.stream.add sender: sender, raw: data.text, type: 'notice'

	irc.socket.on 'motd', (data) ->
		message = new Message sender: 'status', raw: data.motd, type: 'motd'
		irc.chatWindows.getByName('status').stream.add message

	irc.socket.on 'whois', (data) ->
		stream = irc.chatWindows.getByName('status').stream
		if data.info
			info:
				" ": data.info.nick + ' (' + data.info.user + '@' + data.info.host + ')'
				realname: data.info.realname
				server: data.info.server + ' (' + data.info.serverinfo + ')'
				account: data.info.account

			for key in info
				if info.hasOwnProperty(key)
					stream = new Message sender: key, raw: info[key], type: 'whois'
					stream.add message
	# --> End

	irc.socket.on 'message', (data) ->
		chatWindow = irc.chatWindows.getByName(data.to.toLowerCase())
		type = 'message'
		if data.to.substr(0, 1) is '#'
			chatWindow.stream.add sender: data.from, raw: data.text, type: type
		else if data.to isnt irc.me.get('nick')
			chatWindow.stream.add sender: data.from.toLowerCase(), raw: data.text, type: 'pm'

	irc.socket.on 'pm', (data) ->
		chatWindow = irc.chatWindows.getByName(data.nick.toLowerCase())
		if typeof chatWindow is 'undefined'
			irc.chatWindows.add( name: data.nick.toLowerCase(), type: 'pm' ).trigger('forMe', 'newPm')
			irc.socket.emit 'getOldMessages', channelName: data.nick.toLowerCase(), skip: 0, amount: 50
			chatWindow = irc.chatWindows.getByName(data.nick.toLowerCase())
		chatwindow.stream.add sender: data.nick, raw: data.text, type: 'pm'

	irc.socket.on 'join', (data) ->
		chanName = data.channel.toLowerCase()
		if data.nick is irc.me.get('nick')
			irc.chatWindows.add name: chanName
			irc.socket.emit 'getOldMessages', channelName: chanName, skip: 0, amount: 50
		else
			channel = irc.chatWindows.getByName(chanName)
			if typeof channel is 'undefined'
				irc.chatWindows.add name: chanName
				channel = irc.chatWindows.getByName(chanName)
			channel.userList.add nick: data.nick, role: data.role, idle: 0, user_status: 'idle', activity: ''
			joinMessage = new Message type: 'join', nick: data.nick
			channel.stream.add joinMessage
	# --> End

	irc.socket.on 'part', (data) ->
		chanName = data.channel.toLowerCase()
		channel = irc.chatWindows.getByName chanName
		if data.nick is irc.me.get('nick')
			channel.part()
		else
			user = channel.userList.getByNick data.nick
			user.view.remove()
			user.destroy()
			partMessage = new Message type: 'part', nick: data.nick
			channel.stream.add partMessage
	# --> End

	irc.socket.on 'quit', (data) ->



)()