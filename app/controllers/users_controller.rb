# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :authenticate_user!, except: %i[show]
  before_action :set_user

  # GET /users/username or /users/username.json
  def show; end

  # GET /users/username/edit
  def edit; end

  # PATCH/PUT /users/username or /users/username.json
  def update; end

  # DELETE /lists/username or /lists/username.json
  def destroy; end

  private

  def set_user
    @user = User.find_by(username: params[:username])
  end
end
