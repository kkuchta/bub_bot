# Dev instructions

These are just notes to myself.  //TODO: rewrite this section so it's useful to people who are not me.

Use ec2tunnel alias to set up a tunnel (it's already rigged up to slack on the ktest team)

Slack setup:
- Creat an app
- Add a bot user
- Add an event subscription
  - Use the *bot event* for messages.channel
- Add an incoming webhook
<!--- Add event subscription-->
  <!--- Enter hostname (verification should happen automatically now)-->
  <!--- Add messages.channel permission-->

TODO: figure out how to post to the slack web api.  I really only have the bot and non-bot oauth tokens.  What do I do with those?  They're install-specific.

Ok, never mind- let's just use incoming webhooks for that.  They're install-specific too.
