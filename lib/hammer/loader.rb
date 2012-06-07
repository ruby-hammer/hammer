# loads all given files in a safe way
# @example
#   Hammer::Loader.new(Dir.glob('./**/*.rb')).load!
class Hammer::Loader

  # @param [Array<String>] files to load
  def initialize(files)
    @load = files
    @loaded = []
  end

  # executes loading
  def load!
    until @load.empty? do
      loaded_flag = false
      @load.each do |file|
        loaded_flag |= load_file(file)
      end
      raise error_message if !loaded_flag && @load.present?
    end
  end

  private

  # loads +file+
  # @param [String] file to load
  # @return [Boolean] was file loaded?
  def load_file(file)
    unless loadable?(file)
      return false
    end
    require file
    @loaded.push @load.delete(file)
    return true
  end

  # error message when cyclic dependency
  # print load errors for cyclic files
  def error_message
    @load.each {|f| loadable?(f, true) }
    "These files raise errors: \n#{@load.join("\n")}"
  end

  # determines if is +file+ loadable. Creates fork to determine it safely.
  # @param [String] file
  # @param [Boolean] show_errors if it's true, it prints errors
  # @return [Boolean] if can be +file+ loaded
  def loadable?(file, show_errors = false)
    pid = Process.fork do
      begin
        require file
      rescue Exception => e
        raise e if show_errors
        exit(1)
      end
    end
    Process.wait(pid)
    $?.to_i == 0
  end

end
