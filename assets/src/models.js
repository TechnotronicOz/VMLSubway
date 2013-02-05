// Generated by CoffeeScript 1.4.0
var ChatWindow, Message, User;

Message = Backbone.Model.extend({
  defaults: {
    type: 'message'
  },
  initialize: function() {
    if (this.get('raw')) {
      this.set({
        text: this.get('raw')
      });
    }
    if (this.get('type') === 'message' && this.get('raw').search('\\b' + irc.me.get('nick') + '\\b') !== -1) {
      return this.set({
        mention: true
      });
    }
  },
  parse: function(text) {
    var nick, result, results;
    nick = this.get('sender') || this.collection.channel.get('name');
    result = utils.linkify(text);
    if (nick !== irc.me.get('nick')) {
      results = utils.mentions(result);
    }
    return result;
  }
});

ChatWindow = Backbone.Model.extend({
  defaults: {
    type: 'channel',
    active: true,
    unread: 0,
    unreadMentions: 0
  },
  initialize: function() {
    this.stream = new Stream();
    this.stream.bind('add', this.setUnread, this);
    this.stream.channel = this;
    return this.view = new ChatView({
      model: this
    });
  },
  part: function() {
    return this.destroy();
  },
  setUnread: function(msg) {
    var signal;
    if (this.get('active')) {
      return;
    }
    signal = false;
    if (msg.get('type') === 'message' || msg.get('type') === 'pm') {
      this.set({
        unread: this.get('unread') + 1
      });
    }
    if (this.get('type') === 'pm') {
      signal = true;
    }
    if (msg.get('mention')) {
      this.set({
        unreadMentions: this.get('unreadMentions') + 1
      });
      signal = true;
    }
    if (signal) {
      return this.trigger('forMe', 'message');
    }
  }
});

User = Backbone.Model.extend({
  initialize: function() {},
  defaults: {
    opStatus: ''
  }
});
