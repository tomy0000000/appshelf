# frozen_string_literal: true

class EntriesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_entry, only: %i[show update destroy]
  before_action :set_app, only: %i[create]

  # GET /entries/1 or /entries/1.json
  def show; end

  # POST /entries or /entries.json
  def create
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
      format.html { redirect_to @entry.list, status: :see_other, notice: "App was removed from #{@entry.list.name}" }
      format.json { head :no_content }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_entry
    @entry = Entry.find(params[:id])
  end

  def set_app
    app_id = params['entry'][:app_id]
    @app = App.where(id: app_id).first

    return unless @app.nil?

    Rails.logger.debug { 'NEW APP' }
    response = Faraday.get('https://itunes.apple.com/lookup', { id: app_id })
    @body = JSON.parse(response.body)

    if response.status != 200 || @body['resultCount'].zero?
      Rails.logger.debug { "App with ID #{app_id} does not exist" }
      respond_to do |format|
        format.html do
          redirect_to list_url(List.find(params['entry'][:list_id])), alert: "App with ID #{app_id} does not exist"
        end
        format.json { head :no_content }
      end
    else
      @app = App.create(id: app_id)
      @app.name = @body['results'][0]['trackName']
      @app.description = @body['results'][0]['description']
      @app.artwork = @body['results'][0]['artworkUrl512']
      @app.save!
    end
  end

  # Only allow a list of trusted parameters through.
  def entry_params
    params.require(:entry).permit(:app_id, :list_id)
  end
end