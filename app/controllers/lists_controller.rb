# frozen_string_literal: true

class ListsController < ApplicationController
  before_action :authenticate_user!, except: %i[show]
  before_action :set_list, only: %i[show edit update destroy add find_app]
  before_action :set_apps, only: %i[show edit update destroy]
  before_action :check_view, only: %i[show]
  before_action :check_edit, only: %i[edit update destroy add find_app]

  # GET /lists/1 or /lists/1.json
  def show; end

  # GET /lists/new
  def new
    @list = List.new
  end

  # GET /lists/1/edit
  def edit; end

  # POST /lists or /lists.json
  def create
    @list = List.new(list_params)

    respond_to do |format|
      if @list.save
        format.html { redirect_to list_url(@list), notice: 'List was successfully created.' }
        format.json { render :show, status: :created, location: @list }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @list.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /lists/1 or /lists/1.json
  def update
    respond_to do |format|
      if @list.update(list_params)
        format.html { redirect_to list_url(@list), notice: 'List was successfully updated.' }
        format.json { render :show, status: :ok, location: @list }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @list.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /lists/1 or /lists/1.json
  def destroy
    @list.destroy

    respond_to do |format|
      format.html { redirect_to lists_url, notice: 'List was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # GET /lists/1/add
  def add; end

  # POST /lists/1/add
  def find_app
    return unless params[:name] && params[:country]

    @apps = AppSearch.call(params[:name], params[:country])
    respond_to do |format|
      format.turbo_stream
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_list
    @list = List.find(params[:id])
    @is_owner = current_user && @list.user_id == current_user.id
  end

  def set_apps
    @apps = App.find(@list.entries.map(&:app_id))
  end

  def check_view
    return if @is_owner || @list.public

    render file: Rails.public_path.join('404.html'), status: :not_found, layout: false
  end

  def check_edit
    return if @is_owner

    render file: Rails.public_path.join('404.html'), status: :not_found, layout: false
  end

  # Only allow a list of trusted parameters through.
  def list_params
    params.require(:list).permit(:name, :description, :user_id, :public)
  end
end
