require 'git'

class Repo
  # When we create a temproary remote to push to, use this name.
  PUSH_REMOTE_NAME = 'push_remote'

  def initialize(target, origin_remote, server)
    puts "target = #{target}"
    puts "remote = #{origin_remote}"
    puts "server = #{server}"
    @target = target
    @origin_remote = origin_remote
    @server = server
  end

  # Gets a list of branch names without actually cloning the repo.
  def self.branches(origin_remote)
    puts 'repo.branches'
    # git ls-remote returns a list of lines like this:
    #   ea656e141760b0d8ba49d92506427322120ce945	refs/heads/some-branch-name
    ls_remote_output = `git ls-remote --heads #{origin_remote}`
    ls_remote_output.split("\n").map {|line| line.split('/').last }
  end

  def git
    return @_git if @_git

    if Dir.exists?(repo_dir) && Dir.exists?(repo_dir + '/.git')
      puts "Repo exists!"
      @_git = Git.open(repo_dir)
      # TODO: handle other errors beside "dir doesn't exist"
    else
      puts "Cloning repo"
      @_git = Git.clone(@origin_remote, repo_dir_name, path: dir, depth: 1, :log => Logger.new(STDOUT))
      puts 'here'
    end
    @_git
  end

  # Push is async
  def push(branch, remote, &on_complete)
    # TODO: handle people pushing while another push is still going, since we
    # have some shared state in the form of the filesystem

    puts 'Pushing'
    git.remotes.find{ |remote| remote.name == 'push_remote' }&.remove
    puts 'Maybe removed old remote'

    git.add_remote('push_remote', remote)
    puts 'added remote'

    Kernel.system("cd #{repo_dir}; git remote set-branches --add origin '#{branch}'")
    puts "Pushing #{branch} to #{remote}"

    puts "about to git fetch origin for branch #{branch}"
    git.fetch('origin', branch: branch)
    puts 'about to finally push'
    git.push(remote, "+origin/#{branch}:master")
    puts 'Finished final push'
    on_complete.call if on_complete
  end

  def clean
    # TODO: make sure there's no weird changes on the git repo
    git.clean(force: true)
    git.reset_hard
  end

  def fetch
    git.fetch
  end

  def checkout(branch_name)
    clean
    cmd("remote set-branches origin '*'")
    fetch
    git.checkout(branch_name)
  end

  def pull
    git.pull
  end

  # We name repo dirs after server + name (eg `burrito__core`).  This lets
  # multiple deploys to the same server (eg deploying both core and web to burrito
  # at the same time) to work, as well as multiple deploys to the same target
  # (eg deploying core on both burrito and gyro) to work.
  #
  # Note that simultanious deploys to the same target _and_ server (eg two deploys
  # at once to burrito__core) won't work.  Both deploys would use the same git
  # working directory and step on eachother's toes.  That's fine, though, because
  # they'd _also_ step on eachother's toes in the actual target environment.  We
  # should prevent this case in the UI.
  def repo_dir
    "#{dir}/#{repo_dir_name}"
  end

  def repo_dir_name
    "#{@server}__#{@target}"
  end

  def dir
    "/tmp/bub_repos"
  end

  private

  # The git library doesn't support everything, so sometimes we run arbitrary commands.
  def cmd(command)
    git_command = "git --git-dir=#{repo_dir}/.git --work-tree=#{repo_dir} #{command}"
    puts "Running #{git_command}"
    result = Kernel.system(git_command)
    puts "Result=#{result}"
  end
end
