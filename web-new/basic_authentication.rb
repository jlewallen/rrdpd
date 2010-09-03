require 'base64'

module Camping #:nodoc:
  # Camping::BasicAuth can be mixed into a camping application to get Basic Authentication support
  # in the application. The module defines a <tt>service</tt> method that only continues the
  # request chain when proper credentials are given.
  #
  # == Getting Started
  #
  # To activate Basic Authentication for your application:
  #
  # 1. <tt>require 'basic_autentication'</tt> (make sure it's in the ruby search path)
  # 2. Mixin the module: <tt>module YourApp; include Camping::BasicAuth end</tt>. If there are
  #    more modules included into you application which wrap the <tt>service</tt> method, make sure
  #    BasicAuth is the first. This way basic authentication will always be performed before
  #    running other application code.
  # 3. Define an <tt>authenticate</tt> method on your application module that takes a username
  #    and password. The method should return true when the username and password are correct.
  #    Examples:
  #
  #      module Blog
  #        def authenticate(u, p)
  #          [u,p] == ['admin','flapper30]
  #        end
  #        module_function :authenticate
  #      end
  #
  #    or
  #
  #      module Wiki
  #        def authenticate(u, p)
  #          Models::User.find_by_username_and_password u, p
  #        end
  #        module_function :authenticate
  #      end
  #
  # 4. <tt>service</tt> sets <tt>@username</tt> to the username of the person who logged in.
  module BasicAuth
    # Reads the username and password from the headers and returns them.
    def credentials
      if d = %w{REDIRECT_X_HTTP_AUTHORIZATION X-HTTP_AUTHORIZATION HTTP_AUTHORIZATION}.inject([]) \
        { |d, h| env.has_key?(h) ? env[h].to_s.split : d }
        return Base64.decode64(d[1]).split(':')[0..1] if d[0] == 'Basic'
      end
    end

    # The <tt>service</tt> method, when mixed into your application module, wraps around the
    # <tt>service</tt> method defined by Camping. It halts execution of the controllers when
    # your <tt>authenticate</tt> method returns false. See the module documentation how to
    # define your own <tt>authenticate</tt> method.
    def service(*a)
      @username, password = credentials
      app = self.class.name.gsub(/^(\w+)::.+$/, '\1')
      if Kernel.const_get(app).authenticate(@username, password)
        s = super(*a)
      else
        @status = 401
        @headers['Content-type'] = 'text/plain'
        @headers['WWW-Authenticate'] = "Basic realm=\"#{app}\""
        @body = 'Unauthorized'
        s = self
      end
      s
    end
  end
end
