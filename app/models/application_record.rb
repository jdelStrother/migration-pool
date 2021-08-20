class ApplicationRecord < ActiveRecord::Base
  self.abstract_class = true
  connects_to database: {
    writing: :primary,
    reading: :primary,
  }

  # A workaround:
  # def primary_class?
  #   self == ActiveRecord::Base || self.name == "ApplicationRecord"
  # end
end
