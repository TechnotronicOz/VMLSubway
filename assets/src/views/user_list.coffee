UserView = Backbone.View.extend
	initialize: (user) ->
		@user = user

	className: 'userlist_user'

	render: ->
		$(@el).html(ich.userlist_user(@user.model.attributes))
		return @

	addToIdle: ->
		idleTime = @user.model.get('idle') + 1
		if idleTime > 60
			@user.model.set activity: '', user_status: 'idle'
			clearInterval(@intervalTimer)
		else
			@user.model.set
				activity: '(' + idleTime + 'm)'
				idle: idleTime
				user_status: 'active'
			@setStatus() if @intervalTimer is undefined
		@render()

	setStatus: ->
		self = @
		interval = 60 * 1000
		@intervalTimer = setInterval( ->
			self.addToIdle()
		, interval)


UserListView = Backbone.View.extend
	initialize: ->
		@setElement(@collection.channel.view.$('#user-list'))
		@collection.bind 'add', @add, @

	render: ->
		return @

	add: (user) ->
		userView = new UserView model: User
		User.view = userView
		$(@el).append(userView.render().el)