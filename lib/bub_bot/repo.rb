require 'git'

class Repo
  # When we create a temproary remote to push to, use this name.
  PUSH_REMOTE_NAME = 'push_remote'
  def initialize(name, origin_remote)
    @name = name
    @origin_remote = origin_remote
  end

  # TODO: maybe cache this list for a few seconds?
  def branches
    puts 'repo.branches'
    # git ls-remote returns a list of lines like this:
    #   ea656e141760b0d8ba49d92506427322120ce945	refs/heads/some-branch-name
    ls_remote_output = `git ls-remote --heads #{@origin_remote}`
    ls_remote_output.split("\n").map {|line| line.split('/').last }
  end

  def git
    return @_git if @_git

    if Dir.exists?(repo_dir) && Dir.exists?(repo_dir + '/.git')
      puts "Repo exists!"
      @_git = Git.open(repo_dir)
      # TODO: handle other errors beside "dir doesn't exist"
    else
      @_git = Git.clone(@origin_remote, @name, path: dir, depth: 1)
      puts 'here'
    end
    # TODO clone + return a git object
    @_git
  end

  def push(branch, remote)
    # TODO: handle people pushing while another push is still going, since we
    # have some shared state in the form of the filesystem

    puts 'Pushing'
    Thread.new do
      puts 'in thread'
      git.remotes.find{ |remote| remote.name == 'push_remote' }&.remove
      puts 'Maybe removed old remote'

      git.add_remote('push_remote', remote)
      puts 'added remote'

      Kernel.system("cd #{repo_dir}; git remote set-branches --add origin '#{branch}'")
      puts "Would have pushed #{branch} to #{remote}"

      puts "about to git fetch origin for branch #{branch}"
      git.fetch('origin', branch: branch)
      puts 'about to finally push'
      git.push(remote, "+origin/#{branch}:master")
      puts 'Finished final push'
    end
    # TODO
  end

  def clean
    # TODO: make sure there's no weird changes on the git repo
  end

  def fetch
    git.fetch
  end

  def repo_dir
    "#{dir}/#{@name}"
  end
  def dir
    "/tmp/bub_repos"
  end
end
