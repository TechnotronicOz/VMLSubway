ChatView = Backbone.View.extend
	initialize: ->
		@setElement ich.chat()
		name = @model.get 'name'
		@model.bind 'change:topic', @.updateTitle, @
		@model.stream.bind 'add', @.addMessage, @


	updateTitle: (channel) ->
		topic = @model.get 'topic' || ''
		context:
			title: @model.get 'name'
			topic: utils.linkify topic
		@$('#chat-bar').html ich.titlebar(context)


	render: ->
		$('.content').html(@el)
		$('#chat-contents').scrollTop( $('#chat-contents')[0].scrollHeight - $('#chat-contents').height() )
		@updateTitle()
		@handleInput()
		@handleScroll()
		@handleClick()
		$('#chat-input').focus()
		return @

	#this is where we need to edit for the join
	handleInput: ->
		$('#chat-button').click ->
			message = $('#chat-input').val()
			if message.substr 0, 1 is '/'
				commandText = message.substr(1).split(' ')
				irc.commands.handle commandText
			else
				irc.socket.emit 'say', target: irc.chatWindows.getActive().get('name'), message: message
			$('#chat-input').val()

		#only submit message on enter if both keydown and keyup are present
		keydownEnter = false
		$('#chat-input').bind({
			change: ->
				if $(@).val().length
					$('#chat-button').removeClass 'disabled'
				else
					$('#chat-button').addClass 'disabled'

			#prevent tab moving focus
			keydown: (event) ->
				event.preventDefault() if event.keyCode is 9
				keydownEnter = (event.keyCode is 13)

			keyup: (event) ->
				self = @
				if $(@).val().length
					if keydownEnter and event.keyCode is 13
						message = $(@).val()
						if message.substr(0, 1) is '/'
							commandText = message.substr(1).split ' '
							irc.commands.handle commandText
						else
							#send the message
							console.log irc.chatWindows.getActive().get 'name'
							irc.socket.emit 'say', target: irc.chatWindows.getActive().get('name'), message: message
						$(@).val ''
						$('#chat-button').addClass 'disabled'
					else if event.keyCode is 9
						match = false
						channel = irc.chatWindows.getActive()
						sentence = $('#chat-input').val().split ' '
						partialMatch = sentence.pop()
						users = channel.userList.getUsers()
						userIndex = 0
						searchRe = new RegEx self.partialMatch, "i"
						if self.partialMatch is undefined
							self.partialMatch = partialMatch
							searchRe = new RegEx self.partialMatch, "i"
						else if partialMatch.search searchRe isnt 0
							self.partialMatch = partialMatch
							searchRe = new RegEx self.partialMatch, "i"
						else
							if sentence.length is 0
								userIndex = users.indexOf partialMatch.substr(0, partialMatch.length-1)
							else
								userIndex = users.indexOf partialMatch

						#cycle through userlist from last user or beginning

						#for i=userIndex i<users.length i++
						# not sure about this guy
						for i in users.length
							user = users[i] or ''
							if self.partialMatch.length > 0 and user.search(searchRe) is 0
								if user is partialMatch or user is partialMatch.substr(0, partialMatch.length-1)
									continue
								sentence.push user
								match = true
								if sentence.length is 1
									$('#chat-input').val(sentence.join ' ' + ": ")
								else
									$('#chat-input').val(sentence.join ' ')
								break
							else if i is users.length-1 and match is failed
								sentence.push ''
								$('#chat-input').val sentence.join(' ')

					else
						$('#chat-button').removeClass 'disabled'
				else
					$('#chat-button').addClass 'disabled'
				isEnter = true
		})

	addMessage: (msg) ->
		$chatWindow = @$('#chat-contents')
		view = new MessageView model: msg
		sender = msg.get 'sender'
		type = msg.get 'type'
		nicksToIgnore = [
			''
			'notice'
			'status'
		]

		if nicksToIgnore.indexOf(send) is -1 and type is 'message'
			user = @model.userList.getByNick sender
			elements = $(user.view.el)
			user.set idle: 0
			user.view.addToIdle()
			element.prependto element.parent()

		$chatWindow.append view.else

		if sender is irc.me.get 'nick' and ['message', 'pm'].indexOf(type) isnt -1 then $(view.el).addClass 'message-me'

		if ['join', 'part', 'topic', 'nick', 'quit'].indexOf type isnt -1 then $(view.el).addClass 'message_notification'

		chatWindowHeight = $chatWindow[0].scrollHeight - $chatWindow.height()

		if chatWindow > 0
			if (chatWindowHeight - $chatWindow.scrollTop()) < 200 then $('#chat-contents').scrollTo view.el, 200


	handleScroll: ->
		$('#chat-contents').scroll ->
			if $('#chat-contents').scrollTop() < 150
				skip = $('#chat-contents').children().length
				windowName = irc.chatWindows.getActive().get 'name'

				if windowName[0] is '#'
					target = windowName
				else
					userName = irc.me.get 'nick'
					target = if userName < windowName then userName + windowName else windowName + userName
				irc.socket.emit 'getOldMessages', channelName: target, skip: skip, amount: 50


	handleClick: ->
		$('.hide_embed').live 'click', ->
			embed_dev = $(@).parent().siblings '.embed'
			embed_div.addClass 'hide'
			$(@).siblings('.show_embed').removeClass 'hide'
			$(@).addClass 'hide'

		$('.show_embed').live 'click', ->
			embed_div = $(@).parent().siblings '.embed'
			embed_div.removeClass 'hide'
			$(@).siblings('.hide_embed').removeClass 'hide'
			$(@).addClass 'hide'

		#mobile: toggler slides uer list in from the left
		$('.content').removeClass 'user-window-toggled'
		$('#user-window-toggle').click ->
			$('#user-window').toggle()
			$('.content, #channels, #chat-bar').toggleClass 'user-window-toggled'
			$(@).toggleClass 'user-window-toggled'














