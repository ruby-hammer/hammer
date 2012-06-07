class Log4r::Logger
  def exception(e, note = nil)
    message = [(note if note),
               "#{e.class}: #{e.message}",
               e.backtrace.map { |line| "  "+line }.join("\n")].compact
    error { message.join("\n") }
  end
end

class Hammer::Core::Logging

  # TODO observe loggers, implement by new outputter that will generate fire events

  attr_reader :core, :outputter, :formatter

  def initialize(core, options = { })
    @core      = core
    @formatter = options[:formatter] || Log4r::PatternFormatter.new(:pattern => options[:pattern] || '%5l %d %10c: %m')
    @outputter = options[:outputter] || default_outputter
  end

  def [](logger_name)
    logger_name = logger_name.to_s
    Log4r::Logger[logger_name] || begin
      level  = core.config.logger.level[logger_name] || core.config.logger.level.fallback
      logger = Log4r::Logger.new(logger_name, level)
      logger.add @outputter
      logger
    end
  end

  private

  def default_outputter
    outputter = if core.config.logger.output == $stdout
                  Log4r::Outputter.stdout
                else
                  Log4r::RollingFileOutputter.new :filename => core.config.logger.output
                end

    outputter.formatter = formatter
    outputter
  end
end