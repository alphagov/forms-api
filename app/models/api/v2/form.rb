# Currently this is just a facade around the v1 Form model,
# as it uses the same database table
class Api::V2::Form < ApplicationRecord
  self.table_name = "forms"

  def as_json
    { id: external_id }
  end

  def to_param
    external_id
  end
end
