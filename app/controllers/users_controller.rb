class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy]
  before_action :all_users, only: [:index, :friend_request]

  # GET /users
  def index
    render json: @users
  end

  # GET /users/1
  def show
    render json: @user
  end

  # POST /users
  def create
    @user = User.create(user_params)

    render json: @user
  end

  # PUT /users/1
  def update
    @user.update(user_params)

    render json: @user
  end

  # DELETE /users/1
  def destroy
    @user.destroy
  end

  def easter_egg
    render json: "this is a custom response"
  end

  def friend_request
    @random_user = @users[rand(@users.size)]
    # @random_user = @users.sample(1)
    
    render json: @random_user
  end
  
  private
  
  def set_user
    @user = User.find(params[:id])
  end
  
  def all_users
    @users = User.all
  end

  def user_params
    params.require(:user).permit(:name, :age)
  end
end
