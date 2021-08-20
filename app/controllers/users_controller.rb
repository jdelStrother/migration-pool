# frozen_string_literal: true

class UsersController < ApplicationController
  def index
    users = User.pluck(:name)
    app_records = ObjectSpace.each_object(Class).select { |k| k.name == "ApplicationRecord" }
    render inline: <<~TEXT, content_type: "text/plain"
      Current users: #{users}\n
      Instances of ApplicationRecord class:\n
      #{app_records.map { |r| "#{r.inspect}##{r.object_id} primary_class: #{r.primary_class?}"}.join("\n")}
    TEXT
  end
end
