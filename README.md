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

Brain dump for the next time I pick this up:
- I just got messages going both ways (try out the echo command to make sure things work)
- Next up is implementing more commands
  - What do I use for a data store—a db again?  Ugh.
  - Screw that, let's use redis (if heroku allows it for free)
  - It does!
