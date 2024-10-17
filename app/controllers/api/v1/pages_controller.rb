class Api::V1::PagesController < ApplicationController
  def index
    render json: form.pages.to_json
  end

  def create
    new_page = form.pages.new(page_params)

    if new_page.save_and_update_form
      update_form_document
      render json: new_page.to_json, status: :created
    end
  end

  def show
    render json: page.to_json, status: :ok
  end

  def update
    page.assign_attributes(page_params)

    if page.save_and_update_form
      update_form_document
      render json: page.to_json, status: :ok
    end
  end

  def destroy
    page.destroy_and_update_form!
    update_form_document
    render status: :no_content
  end

  def move_down
    unless page.last?
      page.move_lower
      form.update!(question_section_completed: false)
      update_form_document
    end

    render json: page.to_json, status: :ok
  end

  def move_up
    unless page.first?
      page.move_higher
      form.update!(question_section_completed: false)
      update_form_document
    end

    render json: page.to_json, status: :ok
  end

private

  def form
    @form ||= Form.find(params.require(:form_id))
  end

  def page
    @page ||= form.pages.find(params.require(:page_id))
  end

  def answer_settings_hash?
    # these answer_types have an answer_settings value which is a hash
    %w[selection text date address name].include? params[:answer_type]
  end

  def input_type_hash?
    # these answer_types have an input_type value which is a hash
    %w[address].include? params[:answer_type]
  end

  def answer_setting_params
    if answer_settings_hash?
      # answer_types with answer_settings must be whitelisted to pass strong params
      if input_type_hash?
        { answer_settings: [:only_one_option, { selection_options: [:name] }, { input_type: {} }] }
      else
        { answer_settings: [:input_type, :title_needed, :only_one_option, { selection_options: [:name] }] }
      end
    else
      # answer_types with answer_settings will be passed nil, so we just whitelist that
      :answer_settings
    end
  end

  def guidance_params
    %i[page_heading guidance_markdown]
  end

  def page_params
    params.require(:page).permit(
      :id,
      :question_text,
      :hint_text,
      :answer_type,
      :next_page,
      :is_optional,
      :is_repeatable,
      *guidance_params,
      answer_setting_params,
    )
  end

  def update_form_document
    Api::V2::FormDocumentSyncService.new.synchronize_form(form)
  end
end
