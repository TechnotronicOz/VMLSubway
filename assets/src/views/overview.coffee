OverviewView = Backbone.View.extend
	initialize: ->
		@render()

	events:
		'click #connect-button': 'connect'
		'click #connect-more-options-button': 'more_options'
		'click #login-button': 'login_register'
		'click #register-button': 'login_register'
		'keypress': 'connectOnEnter'
		'click #connect-secure': 'toggle_ssl_options'

	el: '.content'

	render: (event) ->
		$(@el).html ich.overview()

		setTimeout (->
			$('#overview').removeClass 'closed'
		), 500

		if event is undefined
			$('#overview').html ich.overview_home()
		else
			func = ich['overview_' + event.currentTarget.id]
			$('#overview').html(func {'loggedIn': irc.loggedIn})

		$('.overview_button').bind 'click', $.proxy(@render, @)

		return @


	connectOnEnter: (event) ->
		return if event.keyCode isnt 13

		@connect event if $('#connect-button').length

		if $('#login-button').length
			event.action = 'Login'
			@login_register event

		if $('#register-button').length
			event.action = 'Register'
			@login_register(event)


	connect: (event) ->
		event.preventDefault()
		$('.error').removeClass 'error'

		server = $('#connect-server').val()
		nick = $('#connect-nick').val()
		port = $('#connect-port').val()
		away = $('#connect-away').val()
		realName = $('#connect-realName').val()
		secure = $('#connect-secure').is(':checked')
		selfSigned = $('#connect-selfSigned').is(':checked')
		rejoin = $('#connect-rejoin').is(':checked')
		password = $('#connect-password').val()
		encoding = $('#connect-encoding').val()
		keepAlve = false

		if not server then $('#connect-server').closest('.control-group').addClass 'error'

		if not nick then $('#connect-nick').closest('.control-group').addClass('error')

		if irc.loggedIn and $('#connect-keep-alive').length then keepAlive = $('#connect-keep-alive').is ':checked'

		if nick and server
			$('form').append ich.load_image()
			$('#connect-button').addClass 'disabled'

			connectInfo:
				nick: nick
				server: server
				port: port
				secure: secure
				selfSigned: selfSigned
				rejoin: rejoin
				away: away
				realName: realName
				password: password
				encoding: encoding
				keepAlive: keepAlive

			irc.me = new User connectInfo
			irc.me.on 'change:nick', irc.appView.renderUserBox
			irc.socket.emit 'connect', connectInfo


	more_options: ->
		@$el.find('.connect-more-options').toggleClass 'hide'


	login_register: (event) ->
		action = event.target.innerHTML.toLowerCase() or event.action.toLowerCase()
		event.preventDefault()
		$('.error').removeClass 'error'

		username = $('#' + action + '-username').val()
		password = $('#' + action + '-password').val()

		if not username
			$('#' + action + '-username').closest('.clearfix').addClass 'error'
			$('#' + action + '-username').addClass 'error'

		if not password
			$('#' + action + '-password').closest('.clearfix').addClass 'error'
			$('#login-password').addClass 'error'

		if username and password
			$('form').append ich.load_image()
			$('#' + action + '-button').addClass 'disabled'

		irc.socket.emit(action, { username: username, password: password })


	toggle_ssl_options: (event) ->
		port = if $('#connect-secure').is(':checked') then 6697 else 6667
		$('#connect-port').attr 'placeholder', port
		$('#ssl-self-signed').toggle()
