class Application < Merb::Controller
  before :authorize

  private
  def authorize
    user, password = Base64.decode64(request.env['HTTP_AUTHORIZATION'].split.last).split(':') rescue [nil, nil]
    cfg = Configuration.global
    unless user == cfg.username and password == cfg.password then
      headers['WWW-Authenticate'] = %{Basic realm="Secure"}
      render("HTTP Basic: Access denied.\n", :status => 401)
      throw :halt
    end
  end
  
end
