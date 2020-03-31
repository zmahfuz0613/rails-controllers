class UsersController < ApplicationController

  # GET /users
  def index
    @users = User.all

    render json: @users
  end

  # GET /users/1
  def show
    @user = User.find(params[:id])

    render json: @user
  end

  # POST /users
  def create
    @user = User.create(params)

    render json: @user
  end

  # PUT /users/1
  def update
    @user = User.find(params[:id])
    @user.update(params)

    render json: @user
  end

  # DELETE /users/1
  def destroy
    @user = User.find(params[:id])

    @user.destroy
  end

end
