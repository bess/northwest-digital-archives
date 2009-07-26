# -*- coding: utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), '..', "helper"))

module Nokogiri
  module HTML
    if RUBY_VERSION =~ /^1\.9/
      class TestDocumentEncoding < Nokogiri::TestCase
        def test_default_to_encoding_from_string
          bad_charset = <<-eohtml
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=charset=UTF-8">
</head>
<body>
  <a href="http://tenderlovemaking.com/">blah!</a>
</body>
</html>
          eohtml
          doc = Nokogiri::HTML(bad_charset)
          assert_equal bad_charset.encoding.name, doc.encoding

          doc = Nokogiri.parse(bad_charset)
          assert_equal bad_charset.encoding.name, doc.encoding
        end

        def test_encoding_with_a_bad_name
          bad_charset = <<-eohtml
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"   "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html>
<head>
  <meta http-equiv="Content-Type" content="text/html; charset=charset=UTF-8">
</head>
<body>
  <a href="http://tenderlovemaking.com/">blah!</a>
</body>
</html>
          eohtml
          doc = Nokogiri::HTML(bad_charset, nil, 'askldjfhalsdfjhlkasdfjh')
          assert_equal ['http://tenderlovemaking.com/'],
            doc.css('a').map { |a| a['href'] }
        end
      end
    end
  end
end
