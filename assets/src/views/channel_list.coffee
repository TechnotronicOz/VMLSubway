TAB_WIDTH = 120
BTN_WIDTH = 34

ChannelListView = Backbone.View.extend
	el: '#channels'

	events:
		'click #slide-prev': 'slidePrev'
		'click #slide-next': 'slideNext'

	initialize: ->
		irc.chatWindows.bind 'add', @addChannel, @
		$('.slide').css 'display', 'inline-block'
		@channelTabs = []


	addChannel: (chatWindow) ->
		$el = $(@el)
		view = new ChannelTabView model: chatWindow
		@channelTabs.push view
		$el.append view.render()

		name = chatWindow.get 'name'

		if name[0] is '#' and name is 'status'
			view.setActive()

			if $el.css('position') is 'fixed' and not (chatWindow.get 'initial')
				$el.css('left', -1 * (@channelTabs.length - 1) *
					TAB_WIDTH + BTN_WIDTH + 'px')


	slidePrev: =>
		setTimeout ( ->
			$el = $(@el)
			return if $el.css('position') isnt 'fixed'

			left = parseInt($el.css('left'), 10)
			if left < BTN_WIDTH then $el.animate({ 'left': left + TAB_WIDTH + 'px'}, 100)
		), 200


	slideNext: =>
		setTimeout ( ->
			$el = $(@el)
			return if $el.css('position') isnt 'fixed'

			left = parseInt($el.css('left'), 10)
			if left >= -1 * (that.channelTabs.length - 2) * TAB_WIDTH
				$el.animate({ 'left': left - TAB_WIDTH + 'px'}, 100)
		), 200
