class Api::V2::FormDocumentsController < ApplicationController
  before_action :set_form_document

  # GET /api/v2/forms/1/{draft,live,archived}
  def show
    render json: @form_document
  end

private

  # Use callbacks to share common setup or constraints between actions.
  def set_form_document
    @form_document = Api::V2::FormDocumentRepository.find(params["form_id"], params["tag"])
  end
end
