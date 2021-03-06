class WorksController < ApplicationController
  before_action :find_a_work, only: [:show, :edit, :update, :destroy, :vote]

  def index
    all_works = Work.all

    all_works.each do |work|
      work.vote_count = work.vote_counter
      work.save
    end
    @works = all_works.order(:vote_count).reverse
  end

  def show
    if @work.nil?
      flash[:error] = "Unknown work!"
      redirect_to works_path
    end
  end

  def new
    @work = Work.new
  end

  def create
    @work = Work.new(work_params)
    if @work.save
      flash[:success] = "Work added successfully!"
      redirect_to work_path(@work.id)
    else
      @work.errors.messages.each do |field, message|
        flash.now[:error] = "#{field.capitalize}: #{message}"
        # raise
      end
      render :new, status: :bad_request
    end
  end

  def edit
  end

  def update
    if @work.update(work_params)
      flash[:success] = "Work updated successfully!"
      redirect_to work_path(@work.id)
    else
      @work.errors.messages.each do |field, message|
        flash.now[:error] = "#{field.capitalize}: #{message}"
      end
      render :edit, status: :bad_request
    end
  end

  def destroy
    if @work.nil?
      flash[:error] = "Work already does not exist."
    else
      @work.destroy
    end
    redirect_to works_path
  end

  def vote
    if @work.nil?
      flash[:error] = "Work no longer exists!"
      redirect_to works_path
      return
    end

    if session[:user_id]
      user_vote_id = session[:user_id]
      vote = Vote.new(user_id: user_vote_id, work_id: @work.id)
      is_successful = vote.save

      if is_successful
        flash[:success] = "Work updated successfully!"
        @work.vote_count = @work.vote_counter
        @work.save
      else
        flash[:error] = "You cannot vote on the same work!"
      end
    else
      flash[:error] = "You must be logged in to vote!"
    end

    redirect_back fallback_location: works_path
  end

  private

  def find_a_work
    @work = Work.find_by(id: params[:id])
  end

  def work_params
    params.require(:work).permit(:category, :title, :creator, :publication_year, :description, :vote_id, :vote_count)
  end
end
