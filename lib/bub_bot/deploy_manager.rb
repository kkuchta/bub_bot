require 'bub_bot/repo'
require 'bub_bot/redis_connection'
require 'erb'

class BubBot::DeployManager
  def deploy(server, target_name, branch)
    if DeployState[server, target_name].deploying?
      raise RespondableError.new("A deploy to #{target_name} on #{server} is already in progress.  Not deploying.")
    end

    begin
      DeployState[server, target_name].set(true)
      target_config = target(target_name, server)

      unless deploy_config = target_config['deploy']
        raise "Missing deploy config for #{target_name}"
      end

      locals = {
        server: server
      }

      # Handle each type of deploy here.
      # TODO: maybe handle multiple deploys for each target?  Right now the
      # workaround to do that is to just have a script-type deploy that does that.
      if deploy_git_remote = deploy_config['git']
        repo(target_name, server).push(branch, deploy_git_remote)
      elsif deploy_script = deploy_config['script']
        puts "xdeploying web script #{deploy_script}"
        repo = repo(target_name, server)
        puts "Checking out..."
        repo.checkout(branch)
        puts "Pulling..."
        repo.pull
        puts "Running script..."
        success = Kernel.system("./#{deploy_script} #{repo.repo_dir} #{branch} #{server}")
        puts "Success = #{success}"
        unless success
          raise RespondableError.new("Deploy script failed for server #{server} and target #{target_name}")
        end
      elsif deploy_url = deploy_config['http']
        raise RespondableError.new('Sorry, deploys by http request are not supported yet')
      end
    ensure
      DeployState[server, target_name].set(false)
    end
  end

  def target_names
    targets.keys - ['all']
  end

  def branches(target_name)
    Repo.branches(target(target_name)['git'])
  end

  private

  def repo(target_name, server)
    @repos ||= {}
    target = target(target_name, server)
    @repos[target_name + '__' + server] ||= Repo.new(target_name, target['git'], server)
  end

  # Returns a hash of config data for the target with this name
  def target(target_name, server = nil)
    targets(server).find { |name, _| name == target_name }.last
  end

  def targets(server = nil)
    BubBot.configuration.deploy_targets(server: server)
  end

  # Gets a binding object with the given variables defined in it.  You'd *think*
  # there'd be a simpler way.  Well, ok, there is, but there's no simpler way that
  # doesn't *also* polute the binding with variables from the outer scope.
  def get_binding(variables)
    obj = Class.new {
      attr_accessor *variables.keys
      def get_binding(); binding end
    }.new
    variables.each { |name, value| obj.public_send(:"#{name}=", value) }
    obj.get_binding
  end
end

class DeployState
  ROOT_KEY = 'bub_deploy_status'.freeze

  def self.[](server, target)
    (@_deploy_states ||= {})[key(server, target)] ||= DeployState.new(server, target)
  end

  def self.key(server, target)
    "#{server}__#{target}"
  end

  def initialize(server, target)
    @server = server
    @target = target
  end

  def key
    self.class.key(@server, @target)
  end

  def deploying?
    deployed_at = redis.hget(ROOT_KEY, key)

    # If we have a super-old deployed_at, assume something went wrong in the
    # deploy and we failed to capture that.
    return deployed_at && Time.parse(deployed_at) > 30.minutes.ago
  end

  def set(is_deploying)
    puts "set deploying to #{is_deploying} for #{key}"
    if is_deploying
      redis.hset(ROOT_KEY, key, Time.now)
    else
      redis.hdel(ROOT_KEY, key)
    end
  end

  def redis
    BubBot::RedisConnection.instance
  end
end
