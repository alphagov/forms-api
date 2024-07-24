class Api::V1::ReportsController < ApplicationController
  def features
    feature_stats = {
      total_forms: forms.count,
      answer_types: { name: number_of_forms_with_answer_type("name"),
                      organisation_name: number_of_forms_with_answer_type("organisation_name"),
                      phone_number: number_of_forms_with_answer_type("phone_number"),
                      email: number_of_forms_with_answer_type("email"),
                      address: number_of_forms_with_answer_type("address"),
                      national_insurance_number: number_of_forms_with_answer_type("national_insurance_number"),
                      date: number_of_forms_with_answer_type("date"),
                      number: number_of_forms_with_answer_type("number"),
                      selection: number_of_forms_with_answer_type("selection"),
                      text: number_of_forms_with_answer_type("text") },
      payment: number_of_forms_with_payments,
    }
    render json: feature_stats.to_json, status: :ok
  end

private

  def forms
    @forms ||= Form.all
  end

  def number_of_forms_with_answer_type(answer_type)
    forms.filter { |form| form.pages.any? { |page| page.answer_type == answer_type } }.count
  end

  def number_of_forms_with_payments
    forms.filter { |form| form.payment_url.present? }.count
  end
end
