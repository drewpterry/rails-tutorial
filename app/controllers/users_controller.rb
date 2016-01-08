class UsersController < ApplicationController
  def new
    @user = User.new
  end
  
  def show
    @user = User.find(params[:id])
    #writes debug information to terminal, allows access to rails console to debug
    #debugger
  end
  
  def create
    @user = User.new(user_params)    # Not the final implementation!
    if @user.save #if successful returns true
      log_in @user
      redirect_to @user #this is saying to redirect to the show page via Rails magic
      flash[:success] = "Welcome to the Sample App!"
    else
        render 'new'
    end
  end
  
  private

      def user_params
        params.require(:user).permit(:name, :email, :password,
                                     :password_confirmation)
      end
end
