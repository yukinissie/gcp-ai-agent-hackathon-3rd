# == Schema Information
#
# Table name: tags
#
#  id         :bigint           not null, primary key
#  category   :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
# Indexes
#
#  index_tags_on_category           (category)
#  index_tags_on_name_and_category  (name,category) UNIQUE
#
require 'rails_helper'

RSpec.describe Tag, type: :model do
  pending "add some examples to (or delete) #{__FILE__}"
end
