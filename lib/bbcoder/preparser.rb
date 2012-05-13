class BBCoder
  class Preparser
    def initialize(text)
      @text = text
    end

    def to_s
      BBCoder.configuration.preparse_tokens.each do |token, options|
        @text.gsub!(token, options[:as])
      end

      @text
    end
  end
end
