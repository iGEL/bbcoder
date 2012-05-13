require 'spec_helper'

describe BBCoder::Preparser do
  before do
    @tags = BBCoder::Configuration.class_variable_get(:@@tags).clone
  end

  after do
    BBCoder::Configuration.class_variable_set(:@@tags, @tags)
    BBCoder::Configuration.class_variable_set(:@@preparse_tokens, {})
  end

  it "should allow to parse smileys" do
    BBCoder.configure do
      tag :img do
        %(<img src="#{content}" alt="#{meta}" />)
      end

      preparse ":-)", ":)", :as => '[img]/images/smileys/smile.png[/img]'
      preparse ":rolleyes:", :as => '[img=:rolleyes:]/images/smileys/rolleyes.gif[/img]'
    end

    "Hello world! :) How do you do? :-) Hope this test works fine :rolleyes:".bbcode_to_html.should == 'Hello world! <img src="/images/smileys/smile.png" alt="" /> How do you do? <img src="/images/smileys/smile.png" alt="" /> Hope this test works fine <img src="/images/smileys/rolleyes.gif" alt=":rolleyes:" />'
  end

  it "should allow to parse links" do
    BBCoder.configure do
      preparse /(\A|[^\]=])(https?:\/\/\S+[^\s.,\)\];:])/, :as => '\1[url]\2[/url]'
      preparse /(\A|[^\]=])(www\.\S+[^\s.,\)\];:])/, :as => '\1[url=http://\2]\2[/url]'
    end

    src = <<-END
http://github.com/asceth/bbcoder
The 2nd test: http://github.com/asceth/bbcoder.html
The 3rd test: https://github.com/asceth/bbcoder.html
The 4th test: (https://github.com/asceth/bbcoder.html)
The 5th test: www.github.com/asceth/bbcoder.html
The 6th test: Go to www.github.com/asceth/bbcoder.html.
The 7th test: Go to www.github.com/asceth/bbcoder, then click on fork.
The 8th test: [url]http://github.com/asceth/bbcoder[/url].
The 9th test: [url=http://github.com/asceth/bbcoder]fork me on github[/url].
    END

    src.bbcode_to_html.should == <<-END
<a href="http://github.com/asceth/bbcoder">http://github.com/asceth/bbcoder</a>
The 2nd test: <a href="http://github.com/asceth/bbcoder.html">http://github.com/asceth/bbcoder.html</a>
The 3rd test: <a href="https://github.com/asceth/bbcoder.html">https://github.com/asceth/bbcoder.html</a>
The 4th test: (<a href="https://github.com/asceth/bbcoder.html">https://github.com/asceth/bbcoder.html</a>)
The 5th test: <a href="http://www.github.com/asceth/bbcoder.html">www.github.com/asceth/bbcoder.html</a>
The 6th test: Go to <a href="http://www.github.com/asceth/bbcoder.html">www.github.com/asceth/bbcoder.html</a>.
The 7th test: Go to <a href="http://www.github.com/asceth/bbcoder">www.github.com/asceth/bbcoder</a>, then click on fork.
The 8th test: <a href="http://github.com/asceth/bbcoder">http://github.com/asceth/bbcoder</a>.
The 9th test: <a href="http://github.com/asceth/bbcoder">fork me on github</a>.
    END
  end

  it "should raise an error, if the last parameter is not a Hash" do
    expect {
      BBCoder.configure do
        preparse ":-)", '[smiley]/images/smileys/smile.png[/smiley]'
      end
    }.to raise_exception
  end

  it "should raise an error, if no as option was given" do
    expect {
      BBCoder.configure do
        preparse ":-)", {}
      end
    }.to raise_exception
  end
end
