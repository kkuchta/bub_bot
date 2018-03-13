require 'bub_bot/repo'
require 'bub_bot/redis_connection'
require 'erb'

class BubBot::DeployManager
  ROOT_KEY = 'bub_deploy_status'.freeze
  def deploy(server, target_name, branch)
    if deploying?(server)
      raise RespondableError.new("A deploy to #{server} is already in progress.")
    end

    begin
      set_deploying(server, true)
      target_config = target(target_name)

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
        deploy_git_remote = ERB.new(deploy_git_remote).result(get_binding(locals))
        repo(target_name).push(branch, deploy_git_remote)
        set_deploying(server, false)
      elsif deploy_script = deploy_config['script']
        # TODO
        raise RespondableError.new('Script deploys arent supported yet; blame kevin')
      end

      puts 'deploying'
    rescue
      set_deploying(server, false)
      raise
    end
  end

  def target_names
    targets.keys - ['all']
  end

  def branches(target_name)
    repo(target_name).branches
  end

  private

  def set_deploying(server, is_deploying)
    puts "set deploying to #{is_deploying} for #{server}"
    if is_deploying
      redis.hset(ROOT_KEY, server, Time.now)
    else
      redis.hdel(ROOT_KEY, server)
    end
  end

  def deploying?(server)
    deployed_at = redis.hget(ROOT_KEY, server)
    # If we have a super-old deployed_at, assume something went wrong in the
    # deploy and we failed to capture that.
    return deployed_at && Time.parse(deployed_at) > 30.minutes.ago
  end

  def redis
    BubBot::RedisConnection.instance
  end

  def repo(target_name)
    @repos ||= {}
    target = targets.find { |name, _| name == target_name }.last
    @repos[target_name] ||= Repo.new(target_name, target['git'])
  end

  # Returns a hash of config data for the target with this name
  def target(target_name)
    targets.find { |name, _| name == target_name }.last
  end

  def targets
    BubBot.configuration.deploy_targets
  end
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
