require 'mkmf'

dir_config('curl')

if find_executable('curl-config')
  $CFLAGS << " #{`curl-config --cflags`.strip}"
  $LIBS << " #{`curl-config --libs`.strip}"
elsif !have_library('curl') or !have_header('curl/curl.h')
  fail <<-EOM
  Can't find libcurl or curl/curl.h

  Try passing --with-curl-dir or --with-curl-lib and --with-curl-include
  options to extconf.
  EOM
end

def define(s)
  $defs.push( format("-D HAVE_%s", s.to_s.upcase) )
end

def have_constant(name)
  checking_for name do
    src = %{
      #include <curl/curl.h>
      int main() {
        int test = (int)#{name.upcase};
        return 0;
      }
    }
    if try_compile(src,"#{$CFLAGS} #{$LIBS}")
      define name
      true
    else
      false
    end
  end
end

have_constant "curlinfo_redirect_time"
have_constant "curlinfo_response_code"
have_constant "curlinfo_filetime"
have_constant "curlinfo_redirect_count"
have_constant "curlinfo_os_errno"
have_constant "curlinfo_num_connects"
have_constant "curlinfo_ftp_entry_path"
have_constant "curl_version_ssl"
have_constant "curl_version_libz"
have_constant "curl_version_ntlm"
have_constant "curl_version_gssnegotiate"
have_constant "curl_version_debug"
have_constant "curl_version_asynchdns"
have_constant "curl_version_spnego"
have_constant "curl_version_largefile"
have_constant "curl_version_idn"
have_constant "curl_version_sspi"
have_constant "curl_version_conv"
have_constant "curlproxy_http"
have_constant "curlproxy_socks4"
have_constant "curlproxy_socks5"
have_constant "curlauth_basic"
have_constant "curlauth_digest"
have_constant "curlauth_gssnegotiate"
have_constant "curlauth_ntlm"
have_constant "curlauth_anysafe"
have_constant "curlauth_any"
have_constant "curle_tftp_notfound"
have_constant "curle_tftp_perm"
have_constant "curle_tftp_diskfull"
have_constant "curle_tftp_illegal"
have_constant "curle_tftp_unknownid"
have_constant "curle_tftp_exists"
have_constant "curle_tftp_nosuchuser"
# older versions of libcurl 7.12
have_constant "curle_send_fail_rewind"
have_constant "curle_ssl_engine_initfailed"
have_constant "curle_login_denied"

# older than 7.16.3
have_constant "curlmopt_maxconnects"
have_constant "curlmopt_pipelining"

if try_compile('int main() { return 0; }','-Wall')
  $CFLAGS << ' -Wall'
end

# do some checking to detect ruby 1.8 hash.c vs ruby 1.9 hash.c
def test_for(name, const, src)
  checking_for name do
    if try_compile(src,"#{$CFLAGS} #{$LIBS}")
      define const
      true
    else
      false
    end
  end
end
test_for("Ruby 1.9 Hash", "RUBY19_HASH", %{
  #include <ruby.h>
  int main() {
    VALUE hash = rb_hash_new();
    if( RHASH(hash)->ntbl->num_entries ) {
      return 0;
    }
    return 1;
  }
})
test_for("Ruby 1.9 st.h", "RUBY19_ST_H", %{
  #include <ruby.h>
  #include <ruby/st.h>
  int main() {
    return 0;
  }
})

test_for("curl_easy_escape", "CURL_EASY_ESCAPE", %{
  #include <curl/curl.h>
  int main() {
    CURL *easy = curl_easy_init();
    curl_easy_escape(easy,"hello",5);
    return 0;
  }
})

create_header('curb_config.h')
create_makefile('curb_core')
