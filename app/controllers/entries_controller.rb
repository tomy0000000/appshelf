# frozen_string_literal: true

class EntriesController < ApplicationController
  before_action :authenticate_user!, except: %i[show]
  before_action :set_entry, only: %i[show edit update destroy]
  before_action :init_app, only: %i[create]
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
  end

  def parse_app_id(app_id)
    match = app_id.match(%r{^((https://)?apps.apple.com/(\w{2})/app(/.+)?/id)?(\d+)$})

    unless match && !match[5].nil?
      respond_to do |format|
        format.html do
          redirect_to list_url(List.find(params['entry'][:list_id])),
                      alert: "Invalid App ID or URL: #{app_id}"
        end
        format.json { head :no_content }
      end
      return
    end

    [match[3].nil? ? 'us' : match[3], match[5]]
  end

  def init_app
    country, app_id = parse_app_id(params['entry'][:app_id])
    return if country.nil? || app_id.nil?

    @app = App.where(id: app_id).first
    return unless @app.nil?

    response = Faraday.get('https://itunes.apple.com/lookup', { id: app_id, country: })
    @body = JSON.parse(response.body)

    if response.status != 200 || @body['resultCount'].zero? || @body['results'][0]['kind'] != 'software'
      respond_to do |format|
        format.html do
          redirect_to list_url(List.find(params['entry'][:list_id])),
                      alert: "App ID #{app_id} is valid but app does not exist"
        end
        format.json { head :no_content }
      end
    else
      @app = App.create(id: app_id)
      @app.name = @body['results'][0]['trackName']
      @app.description = @body['results'][0]['description']
      @app.country = country
      @app.artwork = @body['results'][0]['artworkUrl512']
      @app.save!
    end
  end

  def check_view
    return if @entry.list.public || (current_user && @entry.list.user_id == current_user.id)

    render file: Rails.public_path.join('404.html'), status: :not_found, layout: false
  end

  def check_edit
    return if @entry.list.user_id == current_user.id

    render file: Rails.public_path.join('404.html'), status: :not_found, layout: false
  end

  # Only allow a list of trusted parameters through.
  def entry_params
    params.require(:entry).permit(:app_id, :list_id, :remark)
  end
end
