class Hammer::Runner::Node
  attr_reader :core, :pid, :logger

  def initialize(core)
    @core   = core
    @logger = core.logging['node']
  end

  def run
    logger.info "starting"

    # TODO try gem daemons
    # TODO kill node even if error is risen
    # TODO monitor node

    fork do |pid|
      unless pid
        cmd = "#{core.config.node.executable} #{core.config.root}/hammer/node/server.js " +
            "--host #{core.config.node.web.host} " +
            "--port #{core.config.node.web.port} " +
            "--push #{core.config.node.to_hammer} " +
            "--pull #{core.config.node.to_node} " +
            "--files #{core.config.app.public} "
        cmd << "--logTraffic" if core.config.node.log_traffic
        logger.debug "command: #{cmd}"
        exec cmd
      else
        @pid = pid
      end
    end
  end
end