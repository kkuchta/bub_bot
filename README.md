# Dev instructions

These are just notes to myself.  //TODO: rewrite this section so it's useful to people who are not me.

Use ec2tunnel alias to set up a tunnel (it's already rigged up to slack on the ktest team)
`redis-server --save "" --appendonly no`
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

# Questions
- What's the syntax for deploying different branches to different targets?
  `bub deploy burrito, kk_web_change to web, kk_core_change to core` maybe?  Ideally something simpler.
  - We'll want a shorthand for deploying the same branch to both (`bub deploy burrito kk_small_fixes to both`). Or maybe not.
  - If you leave one off, does it deploy develop, or maybe it doesn't deploy to that branch at all?  eg `bub deploy kk_small_fixes to web`

Brain dump for the next time I pick this up:
- Ok, take command works with hardcoded values.  Let's set up the command parsing.
- Got a cool parsing system in place- still fleshing it out.
- Need to come up with a system that catches exceptions thrown by commands and prints
  the results.  Maybe Command.safe_run is what webserver calls, which wraps run
  in a begin-rescue.

