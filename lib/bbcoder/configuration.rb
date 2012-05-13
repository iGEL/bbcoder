class BBCoder
  class Configuration
    @@tags = {}
    @@preparse_tokens = {}

    def [](value)
      @@tags[value]
    end

    def preparse(*args)
      raise 'Hash required as last argument' unless args.last.is_a?(Hash)
      options = args.pop
      raise 'No :as option given' unless options.has_key?(:as)
      args.each do |arg|
        @@preparse_tokens[arg] = options
      end
    end

    def preparse_tokens
      @@preparse_tokens
    end

    def tag(name, options = {}, &block)
      unless block.nil?
        block.binding.eval <<-EOS
          def meta; @meta; end
          def content; @content; end
          def singular?; @singularity; end
        EOS
      end
      @@tags[name.to_sym] = BBCoder::Tag.new(name.to_sym, options.merge(:block => block))
    end
  end
end

