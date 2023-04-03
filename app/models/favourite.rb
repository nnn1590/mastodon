# frozen_string_literal: true
# == Schema Information
#
# Table name: favourites
#
#  id         :bigint(8)        not null, primary key
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  account_id :bigint(8)        not null
#  status_id  :bigint(8)        not null
#

class Favourite < ApplicationRecord
  include Paginable

  update_index('statuses#status', :status)

  belongs_to :account, inverse_of: :favourites
  belongs_to :status,  inverse_of: :favourites

  attr_accessor :content
  attr_reader :tag

  has_one :notification, as: :activity, dependent: :destroy

  validates :status_id, uniqueness: { scope: :account_id }

  before_validation do
    self.status = status.reblog if status&.reblog?

    if self.content.present? && self.content.start_with?(":") && self.content.end_with?(":") then
      if self.content.count(":") != 2 then
        errors.add(self.content, 'Invalid emoji code')
      else
        @tag = CustomEmoji.from_text(self.content)[0]
      end
    end
  end

  after_create :increment_cache_counters
  after_destroy :decrement_cache_counters

  private

  def increment_cache_counters
    status&.increment_count!(:favourites_count)
  end

  def decrement_cache_counters
    return if association(:status).loaded? && status.marked_for_destruction?
    status&.decrement_count!(:favourites_count)
  end
end
