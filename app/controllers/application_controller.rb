class ApplicationController < ActionController::Base
    before_action :authorize
    protected
    def authorize
        unless User.find_by(id: session[:user_id])
            redirect_to login_url, notice:"Perhaps you still need to sign up?"
        end
    end
end
