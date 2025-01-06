class Api::V2::FormDocumentsController < ApplicationController
  before_action :set_form_document, only: %i[show]

  DEFAULT_PAGE_SIZE = 10

  def index
    tag = params["tag"]

    documents = Api::V2::FormDocument.all
    documents = documents.where(tag:) if tag.present?
    paginated = documents.page(params[:page]).per(params[:per_page] || DEFAULT_PAGE_SIZE).order(:id)

    response.set_header("pagination-total", paginated.total_count.to_s)
    response.set_header("pagination-offset", paginated.offset_value.to_s)
    response.set_header("pagination-limit", paginated.limit_value.to_s)
    render json: paginated
  end

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
