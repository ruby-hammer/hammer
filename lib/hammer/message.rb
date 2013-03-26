module Hammer
  class Message
    ALLOWED_KEYS = [:container_id, :context_id, :app_id, :connection_id, :type, :url, :action_id,
                    :callback_id, :updates, :client_html, :args]

    dictionary         = Hash.new { |hash, key| bad_key!(key) }
    SYMBOLS_TO_STRINGS = dictionary.merge ALLOWED_KEYS.inject({}) { |hash, key|
      hash[key] = key.to_s.camelize(:lower); hash
    }
    STRINGS_TO_SYMBOLS = dictionary.merge SYMBOLS_TO_STRINGS.invert

    def self.new_from_json_hash(hash)
      new translate!(hash, STRINGS_TO_SYMBOLS)
    end

    def self.new_from_hash(hash = {})
      hash.any? { |k, _| bad_key! k unless ALLOWED_KEYS.include? k }
      new hash
    end

    private_class_method :new

    def initialize(hash = {})
      @data = hash
      clean_url!
    end

    ALLOWED_KEYS.each do |key|
      class_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{key}
          @data[:#{key}]
        end

        def #{key}=(value)
          @data[:#{key}] = value
        end
      RUBY
    end

    def to_hash
      hash = @data.dup
      translate! hash, SYMBOLS_TO_STRINGS
      hash
    end

    private

    def self.translate!(hash, dict)
      hash.keys.each do |key|
        hash[dict[key]] = hash.delete(key)
      end
      hash
    end

    def translate!(hash, dict)
      self.class.translate! hash, dict
    end

    def bad_key!(key)
      raise ArgumentError, "unknown key: #{key}"
    end

    def clean_url!
      if @data[:url] && @data[:url][0] == '#'
        @data[:url] = @data[:url][1..-1]
      end
    end

    def to_s
      @data.to_s
    end
  end
end
