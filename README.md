# Dev instructions

These are just notes to myself.  //TODO: rewrite this section so it's useful to people who are not me.

Use ec2tunnel alias to set up a tunnel (it's already rigged up to slack on the ktest team)
`redis-server --save "" --appendonly no`
`bundle exec bin/bub_bot test_config.yml`

Slack setup:
- Creat an app
  https://api.slack.com/apps?new_app=1
  Set the development workspace to your target slack env
- Add a bot user
  - Set display name and user name to yoru desired name (eg bub)
- Add an event subscription
  - Use the *bot event* for message.channels ("Add Bot User Event")
  - Set request url to your_host:123/
- Add an incoming webhook
<!--- Add event subscription-->
  <!--- Enter hostname (verification should happen automatically now)-->
  <!--- Add messages.channel permission-->
- More notes on this in test_config.yml.  Before I ship all this I'll need to test out the slack setup instructions.

# Questions
- What's the syntax for deploying different branches to different targets?
  `bub deploy burrito, kk_web_change to web, kk_core_change to core` maybe?  Ideally something simpler.
  - We'll want a shorthand for deploying the same branch to both (`bub deploy burrito kk_small_fixes to both`). Or maybe not.
  - If you leave one off, does it deploy develop, or maybe it doesn't deploy to that branch at all?  eg `bub deploy kk_small_fixes to web`

# Deploy
- Deploy implicitly takes the server
- `bub deploy cannoli kk_some_change` deploys that branch to both servers on cannoli
  - if that branch is found in both core and web, deploy it
  - if it's found in only one, deploy it there and deploy develop in the other
- `bub deploy cannoli core kk_foo web kk_bar`
  - deploy branches to servers
  - try to accept 'kk_foo to core', 'kk_foo on core', 'core kk_foo'
  - ignore commas and 'and'
- `bub deploy cannoli core kk_foo`
  - if only one target specified, I guess deploy default branch to the other
  - I suppose we want to always deploy to all systems so it's not in a surprising state
    - Maybe support `none` or `skip` as a branch if we want to explicitly skip deploying to it.
- `bub deploy core kk_foo`
  - Takes and deploys to the first available server
  - We *could* have this deploy to any server you already have claimed instead, I guess
    - Seems like that could be surprising (in a bad way)
    - Maybe only do that if you have only one server claimed?
    - I dunno, still seems kinda sketch

# Bugs:
- Show better error when you try to push to a repo you don't have permissions on
- Tests, of course.

# Features to add:
- Allow git ssh keys to be passed in at runtime
- Set up a docker image that people can deploy directly
