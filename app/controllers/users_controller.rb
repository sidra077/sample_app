
class UsersController < ApplicationController
  before_filter :authenticate, :except => [:show, :new, :create]
  before_filter :correct_user, :only => [:edit, :update]
  before_filter :admin_user, :only => :destroy
  
##### New Action ######
  
  def new
  @user = User.new  
  @title = "Sign up"
  end

##### Show Action ######

  def show
    @user = User.find(params[:id])
    @microposts = @user.microposts.paginate(:page => params[:page])
    @title = @user.name
  end
  
#### Index Action ######  

  def index
    @title = "All users"
    @users = User.paginate(:page => params[:page])
  end
  
###### Create Action #####  

def create
  @user = User.new(params[:user])
  if (@user.save)
    sign_in @user
  # Handle a successful save.
  flash[:success] = "Welcome to the Sample Application !"
  redirect_to @user
  else
  @title = "Sign up"
  render 'new'
  end
  
end

######### Edit Action #######

def edit
  @title = "Edit user"
end

######### Update Action #######

def update
 
  if (@user.update_attributes(params[:user]))
    flash[:success] = "Profile updated"
    redirect_to @user
  else
    @title = "Edit user"
    render 'edit'
  end
end

  ##### Following Action ######

    def following
      @title = "Following"
      @user = User.find(params[:id])
      @users = @user.following.paginate(:page => params[:page])
      render 'show_follow'
    end

    def followers
      @title = "Followers"
      @user = User.find(params[:id])
      @users = @user.followers.paginate(:page => params[:page])
      render 'show_follow'
    end


######### Delete Action #######

def destroy
User.find(params[:id]).destroy
flash[:success] = "User destroyed."
redirect_to users_path
end

private
  
  def correct_user
    @user = User.find(params[:id])
    redirect_to(root_path) unless current_user?(@user)
  end
  
  def admin_user
  redirect_to(root_path) unless current_user.admin?
  end


##
end




