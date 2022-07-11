class Repositories::FormsRepository
  def initialize(database)
    @database = database
  end

  def create(name, submission_email)
    @database[:forms].insert(name:, submission_email:)
  end

  def get(form_id)
    @database[:forms].where(id: form_id).all.last
  end

  def get_by_org(org)
    @database[:forms].where(org: org).all
  end

  def update(form_id, name, submission_email)
    @database[:forms].where(id: form_id).update(
      name:,
      submission_email:
    )
  end

  def delete(form_id)
    @database[:forms].where(id: form_id).delete
  end

  def fetch_all
    @database[:forms].all
  end
end
