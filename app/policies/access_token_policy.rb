class AccessTokenPolicy
  attr_reader :access_token, :request

  def initialize(access_token, request)
    @access_token = access_token
    @request = request
  end

  def request?
    access_token.all_permissions? || request.get?
  end
end
