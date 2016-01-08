class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password]) #if user exists with email and has matching password
      # Log the user in and redirect to the user's show page.
      log_in user
      params[:session][:remember_me] == '1' ? remember(user) : forget(user) #this uses the remember helper
      redirect_to user #automatically redirects to user page
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
