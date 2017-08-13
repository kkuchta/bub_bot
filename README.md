# Dev instructions

These are just notes to myself.  //TODO: rewrite this section so it's useful to people who are not me.

Use ec2tunnel alias to set up a tunnel (it's already rigged up to slack on the ktest team)
`bundle exec bin/bub_bot test_config.yml`

Slack setup:
- Creat an app
- Add a bot user
- Add an event subscription
  - Use the *bot event* for messages.channel
- Add an incoming webhook
<!--- Add event subscription-->
  <!--- Enter hostname (verification should happen automatically now)-->
  <!--- Add messages.channel permission-->
- More notes on this in test_config.yml.  Before I ship all this I'll need to test out the slack setup instructions.

Brain dump for the next time I pick this up:
- Ok, I started on the Take command.  Got a redis connection working (probably).  Run redis-server to start that locally.
- Figuring out how I want to do the ServerManager.  Should that be responsible
  for deploying, or just claiming?  Probably the latter, right?
- Ok, take command works with hardcoded values.  Let's set up the command parsing.
