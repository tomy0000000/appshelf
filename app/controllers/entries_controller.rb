# frozen_string_literal: true

class EntriesController < ApplicationController
  before_action :authenticate_user!, except: %i[show]
  before_action :set_entry, only: %i[show edit update destroy]
  before_action :init_app, only: %i[create]
  before_action :prevent_duplicate, only: %i[create]
  before_action :check_view, only: %i[show]
  before_action :check_edit, only: %i[edit update destroy]

  # GET /entries/1 or /entries/1.json
  def show; end

  # GET /entries/1/edit
  def edit; end

  # POST /entries or /entries.json
  def create
    return unless @app

    @entry = Entry.new(entry_params)
    @entry.app = @app

    respond_to do |format|
      if @entry.save!
        format.html { redirect_to list_url(@entry.list), notice: "#{@app.name} was successfully added." }
        format.json { render :show, status: :created, location: @entry }
      else
        format.html { redirect_to list_url(@entry.list), status: :unprocessable_entity }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /entries/1 or /entries/1.json
  def update
    respond_to do |format|
      if @entry.update(entry_params)
        format.html { redirect_to entry_url(@entry), notice: 'Entry was successfully updated.' }
        format.json { render :show, status: :ok, location: @entry }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @entry.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /entries/1 or /entries/1.json
  def destroy
    @entry.destroy

    respond_to do |format|
      format.html do
        redirect_to @entry.list, status: :see_other, notice: "#{@entry.app.name} was removed from #{@entry.list.name}"
      end
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_entry
    @entry = Entry.find(params[:id])
    @is_owner = current_user && @entry.list.user_id == current_user.id
  end

  def init_app
    country, app_id = AppIdParser.call(params['entry'][:app_id])
    return if country.nil? || app_id.nil?

    @app = App.where(id: app_id).first
    return unless @app.nil?

    app = AppLookup.call(app_id, country)
    if app.nil?
      respond_to do |format|
        format.html do
          redirect_to list_url(List.find(params['entry'][:list_id])),
                      alert: "App ID #{app_id} is valid but app does not exist"
        end
        format.json { head :no_content }
      end
    else
      @app = App.create(id: app_id)
      @app.name = app['trackName']
      @app.description = app['description']
      @app.country = country
      @app.artwork = app['artworkUrl512']
      @app.save!
    end
  end

  def prevent_duplicate
    return if @app.nil?

    duplicate = Entry.where(list_id: params['entry'][:list_id], app_id: @app.id).first
    return if duplicate.nil?

    respond_to do |format|
      format.html do
        redirect_to list_url(List.find(params['entry'][:list_id])),
                    alert: "#{duplicate.app.name} is already in this list"
      end
      format.json { head :no_content }
    end
  end

  def check_view
    return if @is_owner || @entry.list.public

    render file: Rails.public_path.join('404.html'), status: :not_found, layout: false
  end

  def check_edit
    return if @is_owner

    render file: Rails.public_path.join('404.html'), status: :not_found, layout: false
  end

  # Only allow a list of trusted parameters through.
  def entry_params
    params.require(:entry).permit(:app_id, :list_id, :remark)
  end
end
