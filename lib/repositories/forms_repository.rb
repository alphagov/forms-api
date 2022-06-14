class Repositories::FormsRepository
  def initialize(database)
    @database = database
  end

  def create(name, submission_email)
    @database[:forms].insert(name: name, submission_email: submission_email)
  end

  def get(form_id)
    @database[:forms].where(id: form_id).all.last
  end

  def update(form_id, name, submission_email)
    @database[:forms].where(id: form_id).update(
      name: name,
      submission_email: submission_email
    )
  end

  def delete(form_id)
    @database[:forms].where(id: form_id).delete
  end

  def get_all
    @database[:forms].all
  end
end
