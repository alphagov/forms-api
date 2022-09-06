class Repositories::FormsRepository
  def initialize(database)
    @database = database
  end

  def create(name, submission_email, org)
    @database[:forms].insert(name:, submission_email:, org:, created_at: Time.now, updated_at: Time.now, form_slug: name.parameterize)
  end

  def get(form_id)
    @database[:forms].where(id: form_id).all.last
  end

  def get_by_org(org)
    @database[:forms].where(org:).all
  end

  def update(form)
    if form[:live_at]
      the_form = @database[:forms].where(id: form[:form_id])
      raise "Invalid email" unless form[:submission_email].include?("@")
      raise "Form has no name" unless form[:name]
      raise "Form has no pages" unless @database[:pages].where(form_id: form[:form_id]).count > 0
      raise "Form has a privacy policy" unless form[:privacy_policy_url]
    end

    @database[:forms].where(id: form[:form_id]).update(
      name: form[:name],
      submission_email: form[:submission_email],
      org: form[:org],
      live_at: form[:live_at],
      privacy_policy_url: form[:privacy_policy_url],
      what_happens_next_text: form[:what_happens_next_text],
      form_slug: form[:name].parameterize,
      updated_at: Time.now
    )
  end

  def delete(form_id)
    @database[:pages].where(form_id:).delete
    @database[:forms].where(id: form_id).delete
  end

  def fetch_all
    @database[:forms].all
  end
end
