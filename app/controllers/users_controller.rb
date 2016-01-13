class UsersController < ApplicationController
  before_action :logged_in_user, only: [:index, :edit, :update, :destroy] #run logged_in_user before anything else if eit or update is called
  before_action :correct_user,   only: [:edit, :update]
  before_action :admin_user,     only: :destroy #needed in case there are people using the command line to delete users, this verifies that hte person is an admin
  def new
    @user = User.new
  end

  def index
    # @users = User.paginate(page: params[:page]) #params page is automatically generated
    @users = User.where(activated: true).paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(page: params[:page])
    redirect_to root_url and return unless @user.activated?
  end
  
  def create
    @user = User.new(user_params)    # Not the final implementation!
    if @user.save #if successful returns true
      @user.send_activation_email
      flash[:info] = "Please check your email to activate your account."
      redirect_to root_url
    else
        render 'new'
    end
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params) #here user parameters are the potential user fields (name, email etc)
      # Handle a successful update.
      flash[:success] = "Profile updated"
            redirect_to @user
    else
      render 'edit'
    end
  end

  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  private

      def user_params
        params.require(:user).permit(:name, :email, :password,
                                     :password_confirmation,)
      end

      # Confirms the correct user.
      def correct_user
        @user = User.find(params[:id])
        redirect_to(root_url) unless current_user?(@user) #current user comes from the session helper which is included in the application controller
      end
      
      def admin_user
        redirect_to(root_url) unless current_user.admin?
      end
end
