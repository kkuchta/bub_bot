This is a running log of whatever I was thinking when I stopped work for the day.

Brain dump for the next time I pick this up:
- Ok, `take` works.  There's a nice litle parsing system for flexible command parsing.
- We've got a custom error class that, if thrown, prints the error message to slack too.
- Next up: rubocop + some cleanup, then start in on the deploy command.
 - Deploy should be largely configured by the config mechanisms
  - Although there should be helpers for common deploy strategies (eg git pushing and/or running a script)
- Ok, I described the deploy command in the readme.  I also put together an example config in test_config.yml for deploys.  Now all you have to do is actually implement it.


- Ok, I've written most of the deploy command's parsing.  It probably works, but it'll need testing.  Also needs more error handling.  See the TODOs in the command file.
- Next up is implementing the git logic.
  - Old bub implemented deploy by just cloning, then pushing, then deleting it all.
  - New bub needs to keep a persistent git repo around, if only so we can get a list of branch names to check commands against.
  - Might need a repo manager class to keep track of the state of those things.

I wrote a bunch of git integration stuff, but it turns out you can get a list of remote branches _without_ cloning the rep!  So most of my work today isn't needed yet (although it might be for deploying).
  - If I want to, I can do the old clone->deploy->delete cycle for deploys.
  - Alternately, I can try to keep the repo around between deploys to speed things up.

So I ended up using most of that git stuff anyway.  This is because... git deploy now works!  Woo!  We're even reusing repos!  Todo next:
- Clean up the deploy command (it needs to support more things, like "take latest" and "claim whatever we're deploying to").
- Make sure we're only deploying to one repo at a time.  We _could_ use nora's solution of just cloning a separate copy of the repo for each deploy, but I'd prefer to be able to reuse repos.
  - Actually, maybe this isn't much of an issue?  We only need to keep a lock on a repo while we're getting set up for a deploy.  Once git push starts, we don't care that much about what happens to the filesystem.
- Implement script-based deploys (for web)
- Implement before/after deploy hooks (eg for turning envs on and off when not in use)
  - Wait, maybe this should be handled separately.
