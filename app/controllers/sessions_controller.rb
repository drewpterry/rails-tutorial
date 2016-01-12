class SessionsController < ApplicationController
  def new
  end

  def create
    @user = User.find_by(email: params[:session][:email].downcase)
    if @user && @user.authenticate(params[:session][:password]) #if user exists with email and has matching password
      if @user.activated?
        log_in @user
        #params is either POST info or URL passed info
        params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
        redirect_back_or @user
      else
        message  = "Account not activated. "
        message += "Check your email for the activation link."
        flash[:warning] = message
        redirect_to root_url
      end

    else
    flash.now[:danger] = 'Invalid email/password combination' # Not quite right!
    render 'new' #doesn't count as a request so flash will display for multiple pages unless it is flash.now
    end  
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end
  
end
