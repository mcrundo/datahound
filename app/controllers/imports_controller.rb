class ImportsController < ApplicationController
  def new
  end

  def create
    file = params.require(:import).permit(:file)[:file]

    if file.blank?
      flash.now[:error] = "Please select a CSV file to upload."
      render :new, status: :unprocessable_entity
      return
    end

    import = Import.new(file: file)

    if import.save
      ImportQuotesJob.perform_later(import.id)
      redirect_to quotes_path(import_id: import.id)
    else
      flash.now[:error] = import.errors.full_messages.to_sentence
      render :new, status: :unprocessable_entity
    end
  end
end
