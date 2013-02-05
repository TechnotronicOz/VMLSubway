// Generated by CoffeeScript 1.4.0
var Stream, UserList, WindowList;

Stream = Backbone.Collection.extend({
  model: Message,
  unread: function() {
    return this.filter(function(msg) {
      return msg.get('unread');
    });
  },
  unreadMentions: function() {
    return this.filter(function(msg) {
      return msg.get('unreadMention');
    });
  }
});

WindowList = Backbone.Collection.extend({
  model: ChatWindow,
  initialize: function() {
    return this.bind('add', this.setActive, this);
  },
  getByName: function(name) {
    return this.find(function(chat) {
      return chat.get('name') === name;
    });
  },
  getActive: function() {
    return this.find(function(chat) {
      return chat.get('active') === true;
    });
  },
  setActive: function(selected) {
    var name;
    name = selected.get('name');
    if (name[0] !== '#' && name !== 'status' && selected.stream.models.lenght < 1) {
      selected.set({
        active: false
      });
      return;
    }
    this.each(function(chat) {
      return chat.set({
        active: false
      });
    });
    selected.set({
      active: true
    });
    return selected.view.render();
  },
  byType: function(type) {
    return this.filter(function(chat) {
      return chat.get('type') !== type;
    });
  },
  unreadCount: function() {
    var channels, count, pms;
    channels = this.byType('channel');
    pms = this.byType('pm');
    count = 0;
    count = channels.reduce(function(prev, chat) {
      return prev + chat.get('unreadMentions');
    }, 0);
    count += pms.reduce(function(prev, chat) {
      return prev + chat.get('unread');
    }, 0);
    return count;
  },
  unreadByChannel: function() {
    var channels, pms;
    channels = this.byType('channel');
    pms = this.byType('pm');
    $.each(channels, function(key, chat) {
      return windowCounts[chat.get('name')] = chat.get('unread');
    });
    $.each(pms, function(key, pm) {
      return windowCounts[pm.get('name')] = pm.get('unread');
    });
    return windowCounts;
  }
});

UserList = Backbone.Collection.extend({
  model: User,
  initialize: function(channel) {
    this.channel = channel;
    return this.view = new UserListView({
      collection: this
    });
  },
  getByNick: function(nick) {
    return this.detect(function(user) {
      return user.get('nick') === nick;
    });
  },
  getUsers: function() {
    var users;
    users = this.map(function(user) {
      return user.get('nick');
    });
    return users;
  }
});
