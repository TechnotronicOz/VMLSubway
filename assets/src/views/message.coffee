MessageView = Backbone.View.extend
	initialize: ->
		@render()

	className: 'message-box'

	render: ->
		nick = @model.get 'sender' or @model.collection.channel.get 'name'

		if _.include(['join', 'part', 'nick', 'topic', 'quit'], @model.get 'type')
			html = @setText @model.get('type')
		else if @model.get('text') and @model.get('text').substr(1, 6) is 'ACTION'
			html = ich.action(
				user: nick
				content: @model.get('text').substr(8)
				renderedTime: utils.formatDate(Date.now())
			, true)
			html = @model.parse(html)
		else
			html = ich.message(
				user: nick
				type: @model.get('type')
				content: @model.get('text')
				renderedTime: utils.formatDate(Date.now())
			, true)
			html = @model.parse(html)

		$(@el).html(html)
		return @


	setText: (type) ->
		html = ''
		switch type
			when 'join', 'part'
				html = ich.join_part(
					type: type
					nick: @model.get('nick')
					action: if type is 'join' then 'joined' else 'left'
				)
			when 'quit'
				html = ich.join_part(
					type: 'part'
					nick: @model.get('nick')
					action: 'left'
					reason: if @model.get('reason') isnt 'undefined' then '('+@model.get('reason')+')' else '(leaving)'
				)
			when 'nick'
				html = ich.nick(
					oldNick: @model.get('oldNick')
					newNick: @model.get('newNick')
				)
			when 'topic'
				html = '<span class="topic_img"></span><b>' + @model.get('nick') + '</b> has changed the topic to <i>' + @model.get('topic') + '</i>'

		return html




