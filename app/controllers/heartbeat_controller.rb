class HeartbeatController < ApplicationController
  skip_before_action :authenticate_request

  def ping
    render(body: "PONG")
  end
end
