# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!, except: %i[show]
  before_action :set_user
  before_action :check_view, only: %i[show]
  before_action :check_modify, only: %i[edit update bye destroy]

  # GET /users/username or /users/username.json
  def show; end

  # GET /users/username/edit
  def edit; end

  # PATCH/PUT /users/username or /users/username.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to user_url(@user.username), notice: 'User setting saved.' }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # GET /user/username/bye
  def bye; end

  # DELETE /users/username or /users/username.json
  def destroy
    respond_to do |format|
      if user_params[:username] == @user.username
        @user.destroy

        format.html do
          redirect_to new_user_session_path, status: :see_other,
                                             notice: "#{@user.username} was deleted, we're sad to see you go."
        end
        format.json { render :show, status: :ok, location: new_user_session_path }
      else
        @user.errors.add('username', "You should input your username '#{@user.username}' here.")
        format.html { render :bye, status: :unprocessable_entity }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  private

  def set_user
    @user = User.find_by(username: params[:username])
  end

  def check_view
    return if @user.public || (current_user && @user.id == current_user.id)

    render file: Rails.public_path.join('404.html'), status: :not_found, layout: false
  end

  def check_modify
    return if @user.id == current_user.id

    render file: Rails.public_path.join('404.html'), status: :not_found, layout: false
  end

  # Only allow a user of trusted parameters through.
  def user_params
    params.require(:user).permit(:username, :public)
  end
end
